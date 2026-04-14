#!/usr/bin/env ruby
# generate_lao_svgs.rb
# Generates SVG template files for Lao character stroke order annotation.
# Reads character data from assets/lao_characters.json for rich metadata.
# Each SVG contains:
#   - Embedded metadata (Unicode codepoint, name, phase, romanization, etc.)
#   - Rich character names (letterName, letterNameRomanized, acrophonicalMeaning)
#   - A locked reference layer showing the character in Noto Lao font
#   - An empty <g id="strokes"> layer where you draw center-line stroke paths
#
# Usage: ruby generate_lao_svgs.rb [output_dir] [--force]
# Default output dir: ./lao_svgs
# Skips existing files unless --force/-f is passed.

require 'fileutils'
require 'json'
require 'base64'
require 'tempfile'

args = ARGV.reject { |a| a.start_with?('-') }
OUTPUT_DIR = args[0] || './lao_svgs'
SVG_SIZE   = 512   # canvas px
FONT_SIZE  = 380   # character display size

# ---------------------------------------------------------------------------
# Load character data from JSON
# ---------------------------------------------------------------------------

JSON_PATH = File.join(File.dirname(__FILE__), 'assets', 'lao_characters.json')
RAW_DATA  = JSON.parse(File.read(JSON_PATH, encoding: 'UTF-8'))

# Build a unified character list from all categories in the JSON.
# Each entry is a hash with normalized keys:
#   phase, order, codepoint (int), char, name, romanization, notes,
#   letter_name, letter_name_romanized, acrophonical_meaning
CHARACTERS = []

# --- Consonants ---
RAW_DATA['consonants'].each do |c|
  cp = c['codepoint'].sub('U+', '').to_i(16)
  # Derive short name from letterNameRomanized (first word)
  short_name = c['letterNameRomanized'].split(' ').first.gsub(/[ɔɤɯɛ]/, 'o')
  CHARACTERS << {
    phase: c['phase'],
    order: c['order'],
    codepoint: cp,
    name: short_name,
    romanization: c['consonantIPA']&.gsub(/[\/]/, '') || '',
    notes: [c['toneClass'], c['notes']].compact.reject(&:empty?).join('; '),
    letter_name: c['letterName'],
    letter_name_romanized: c['letterNameRomanized'],
    acrophonical_meaning: c['acrophonicalMeaning'],
  }
end

# --- Vowels ---
# Combining marks need a base consonant to render correctly.
# Use ອ (U+0EAD, the standard Lao vowel anchor) as the base — this is how
# Lao textbooks display vowels. Smaller font size since it's 2 characters.
BASE_CONSONANT = [0x0EAD].pack('U')  # ອ

RAW_DATA['vowels'].each do |v|
  cp = v['codepoint'].sub('U+', '').to_i(16)
  mark = [cp].pack('U')
  position = v['position']

  # Build display string: base consonant + vowel mark in correct position
  display_char = case position
                 when 'above', 'below'
                   BASE_CONSONANT + mark
                 when 'before'
                   mark + BASE_CONSONANT
                 when 'after'
                   BASE_CONSONANT + mark
                 else
                   mark
                 end

  CHARACTERS << {
    phase: v['phase'],
    order: v['order'],
    codepoint: cp,
    name: v['vowelNameRomanized'],
    romanization: v['vowelIPA']&.gsub(/[\/]/, '') || '',
    notes: [v['vowelLength'], v['position'], v['notes']].compact.reject(&:empty?).join('; '),
    letter_name: v['vowelName'],
    letter_name_romanized: v['vowelNameRomanized'],
    acrophonical_meaning: nil,
    display_char: display_char,
    combining: true,
  }
end

# --- Tone Marks ---
# All tone marks are combining (above consonant) — use ອ as base.
RAW_DATA['toneMarks'].each do |t|
  cp = t['codepoint'].sub('U+', '').to_i(16)
  mark = [cp].pack('U')
  CHARACTERS << {
    phase: t['phase'],
    order: t['order'],
    codepoint: cp,
    name: t['toneNameRomanized'],
    romanization: t['toneNumber'].to_s,
    notes: t['notes'] || '',
    letter_name: t['toneName'],
    letter_name_romanized: t['toneNameRomanized'],
    acrophonical_meaning: nil,
    display_char: BASE_CONSONANT + mark,
    combining: true,
  }
end

# --- Numerals ---
RAW_DATA['numerals'].each do |n|
  cp = n['codepoint'].sub('U+', '').to_i(16)
  names = { 0 => 'zero', 1 => 'one', 2 => 'two', 3 => 'three', 4 => 'four',
            5 => 'five', 6 => 'six', 7 => 'seven', 8 => 'eight', 9 => 'nine' }
  CHARACTERS << {
    phase: n['phase'],
    order: n['order'],
    codepoint: cp,
    name: names[n['value']] || n['value'].to_s,
    romanization: n['value'].to_s,
    notes: '',
    letter_name: n['laoName'],
    letter_name_romanized: nil,
    acrophonical_meaning: nil,
  }
end

# --- Ligatures ---
RAW_DATA['ligatures'].each do |l|
  cp = l['codepoint'].sub('U+', '').to_i(16)
  CHARACTERS << {
    phase: l['phase'],
    order: l['order'],
    codepoint: cp,
    name: l['letterNameRomanized'].split(' ').join('_'),
    romanization: l['consonantIPA']&.gsub(/[\/]/, '') || '',
    notes: [l['toneClass'], l['notes']].compact.reject(&:empty?).join('; '),
    letter_name: l['letterName'],
    letter_name_romanized: l['letterNameRomanized'],
    acrophonical_meaning: nil,
  }
end

# --- Special Characters ---
RAW_DATA['specialCharacters'].each do |s|
  cp = s['codepoint'].sub('U+', '').to_i(16)
  CHARACTERS << {
    phase: s['phase'],
    order: s['order'],
    codepoint: cp,
    name: s['nameRomanized'],
    romanization: '-',
    notes: s['notes'] || s['description'] || '',
    letter_name: s['name'],
    letter_name_romanized: s['nameRomanized'],
    acrophonical_meaning: nil,
  }
end

# Sort by phase, then order
CHARACTERS.sort_by! { |c| [c[:phase], c[:order]] }
CHARACTERS.freeze

# ---------------------------------------------------------------------------
# SVG generation
# ---------------------------------------------------------------------------

def escape_xml(str)
  return '' if str.nil?
  str.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;').gsub('"','&quot;').gsub("'",'&apos;')
end

# Render combining mark reference to a base64-encoded PNG.
# Inkscape can't do Lao complex text shaping, so we pre-render
# the combining character reference using rsvg-convert (which uses
# system text layout) and embed the result as an image.
def render_combining_reference_png(display_char, base_char, size, center, baseline_y, fs)
  ref_svg = <<~SVG.lstrip
    <?xml version="1.0" encoding="UTF-8"?>
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
         width="#{size}" height="#{size}" viewBox="0 0 #{size} #{size}">
      <text x="#{center}" y="#{baseline_y}"
            font-family="'Noto Lao UI', 'Noto Lao', 'Phetsarath OT', 'Saysettha OT', sans-serif"
            font-size="#{fs}" text-anchor="middle" fill="#0066cc" opacity="0.10"
      >#{escape_xml(base_char)}</text>
      <text x="#{center}" y="#{baseline_y}"
            font-family="'Noto Lao UI', 'Noto Lao', 'Phetsarath OT', 'Saysettha OT', sans-serif"
            font-size="#{fs}" text-anchor="middle" fill="#0066cc" opacity="0.25"
      >#{escape_xml(display_char)}</text>
    </svg>
  SVG

  svg_tmp = Tempfile.new(['lao_ref_', '.svg'])
  png_tmp = Tempfile.new(['lao_ref_', '.png'])
  begin
    svg_tmp.write(ref_svg)
    svg_tmp.close
    png_tmp.close

    system('rsvg-convert', svg_tmp.path, '-o', png_tmp.path)
    png_data = File.binread(png_tmp.path)
    Base64.strict_encode64(png_data)
  ensure
    svg_tmp.unlink
    png_tmp.unlink
  end
end

def char_from_codepoint(cp)
  [cp].pack('U')
end

def filename(phase, order, name, codepoint)
  safe_name = name.to_s.gsub(/\s+/, '_').gsub(/[^a-z0-9_]/i, '')
  hex = format('U%04X', codepoint)
  format('%02d_%02d_%s_%s.svg', phase, order, safe_name, hex)
end

def generate_svg(entry)
  phase = entry[:phase]
  order = entry[:order]
  codepoint = entry[:codepoint]
  name  = entry[:name]
  romanization = entry[:romanization]
  notes = entry[:notes]
  letter_name = entry[:letter_name]
  letter_name_romanized = entry[:letter_name_romanized]
  acrophonical_meaning = entry[:acrophonical_meaning]

  char   = char_from_codepoint(codepoint)
  display = entry[:display_char] || char  # Use display_char for combining marks
  is_combining = entry[:combining]
  hex    = format('U+%04X', codepoint)
  fname  = filename(phase, order, name, codepoint)
  size   = SVG_SIZE
  center = size / 2.0
  # Combining marks use smaller font (base + mark = wider) and center differently
  fs     = is_combining ? 300 : FONT_SIZE

  # Baseline offset: visually center the glyph.
  baseline_y = (size * 0.65).round

  # Build optional data attributes
  extra_attrs = ""
  extra_attrs += "\n      data-lao-letter-name=\"#{escape_xml(letter_name)}\"" if letter_name
  extra_attrs += "\n      data-lao-letter-name-romanized=\"#{escape_xml(letter_name_romanized)}\"" if letter_name_romanized
  extra_attrs += "\n      data-lao-acrophonical-meaning=\"#{escape_xml(acrophonical_meaning)}\"" if acrophonical_meaning

  # Build optional metadata elements
  extra_meta = ""
  extra_meta += "\n          <lao:letter-name>#{escape_xml(letter_name)}</lao:letter-name>" if letter_name
  extra_meta += "\n          <lao:letter-name-romanized>#{escape_xml(letter_name_romanized)}</lao:letter-name-romanized>" if letter_name_romanized
  extra_meta += "\n          <lao:acrophonical-meaning>#{escape_xml(acrophonical_meaning)}</lao:acrophonical-meaning>" if acrophonical_meaning

  # Label line: show rich name if available
  label_text = "#{escape_xml(char)}  #{hex}  #{escape_xml(letter_name_romanized || name)}"
  label_text += "  (#{escape_xml(acrophonical_meaning)})" if acrophonical_meaning

  svg = <<~SVG.lstrip
    <?xml version="1.0" encoding="UTF-8"?>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      xmlns:lao="https://github.com/your-project/lao-stroke-data"
      width="#{size}"
      height="#{size}"
      viewBox="0 0 #{size} #{size}"
      data-lao-char="#{escape_xml(char)}"
      data-lao-codepoint="#{hex}"
      data-lao-name="#{escape_xml(name)}"
      data-lao-romanization="#{escape_xml(romanization)}"
      data-lao-phase="#{phase}"
      data-lao-order="#{order}"
      data-lao-notes="#{escape_xml(notes)}"
      data-stroke-count=""#{extra_attrs}
    >

      <!-- ============================================================
           METADATA
           stroke-count: fill in after you draw strokes
           strokes: will be populated by your encoding tool
           ============================================================ -->
      <metadata>
        <lao:character>
          <lao:codepoint>#{hex}</lao:codepoint>
          <lao:char>#{escape_xml(char)}</lao:char>
          <lao:name>#{escape_xml(name)}</lao:name>
          <lao:romanization>#{escape_xml(romanization)}</lao:romanization>
          <lao:phase>#{phase}</lao:phase>
          <lao:order>#{order}</lao:order>
          <lao:notes>#{escape_xml(notes)}</lao:notes>#{extra_meta}
          <lao:stroke-count></lao:stroke-count>
          <lao:strokes>
            <!-- Add stroke path data here after drawing. Format:
                 <lao:stroke index="1" direction="clockwise">
                   <lao:path>M x1,y1 C cx1,cy1 cx2,cy2 x2,y2</lao:path>
                   <lao:start-x></lao:start-x>
                   <lao:start-y></lao:start-y>
                 </lao:stroke>
            -->
          </lao:strokes>
        </lao:character>
      </metadata>

      <!-- ============================================================
           BACKGROUND & GUIDE GRID
           ============================================================ -->
      <g id="background">
        <!-- White background -->
        <rect width="#{size}" height="#{size}" fill="white"/>

        <!-- Crosshair guides (light) -->
        <line x1="#{center}" y1="0" x2="#{center}" y2="#{size}"
              stroke="#e8e8e8" stroke-width="1"/>
        <line x1="0" y1="#{center}" x2="#{size}" y2="#{center}"
              stroke="#e8e8e8" stroke-width="1"/>

        <!-- Corner inset box showing safe writing area -->
        <rect x="32" y="32" width="#{size-64}" height="#{size-64}"
              fill="none" stroke="#e0e0e0" stroke-width="1" stroke-dasharray="4,4"/>
      </g>

      <!-- ============================================================
           REFERENCE LAYER — lock this in your SVG editor, trace over it
           The character is rendered semi-transparent as a guide.
           Font stack: Noto Lao UI, Noto Lao, then system Lao fonts.
           If the character doesn't render, install Noto Lao.
           ============================================================ -->
      <g id="reference" pointer-events="none">
#{if is_combining
  # Inkscape can't shape Lao combining marks correctly, so we pre-render
  # the reference as a PNG (via rsvg-convert which uses system text layout)
  # and embed it as an image. This ensures correct rendering everywhere.
  base_char = [0x0EAD].pack('U')
  png_b64 = render_combining_reference_png(display, base_char, size, center, baseline_y, fs)
  <<~COMBINING
        <!-- Pre-rendered reference (Inkscape can't shape Lao combining marks) -->
        <image
          x="0" y="0" width="#{size}" height="#{size}"
          href="data:image/png;base64,#{png_b64}"
        />
  COMBINING
else
  <<~STANDALONE
        <text
          x="#{center}"
          y="#{baseline_y}"
          font-family="'Noto Lao UI', 'Noto Lao', 'Phetsarath OT', 'Saysettha OT', sans-serif"
          font-size="#{fs}"
          text-anchor="middle"
          fill="#0066cc"
          opacity="0.18"
        >#{escape_xml(display)}</text>
  STANDALONE
end}      </g>

      <!-- ============================================================
           LABEL — character info displayed at bottom
           ============================================================ -->
      <g id="label">
        <text
          x="#{center}"
          y="#{size - 36}"
          font-family="monospace, sans-serif"
          font-size="13"
          text-anchor="middle"
          fill="#999"
        >#{label_text}</text>
        <text
          x="#{center}"
          y="#{size - 18}"
          font-family="monospace, sans-serif"
          font-size="11"
          text-anchor="middle"
          fill="#bbb"
        >Phase #{phase} · #{escape_xml(notes)}</text>
      </g>

      <!-- ============================================================
           STROKES LAYER — draw your center-line strokes here.
           Use thin paths (stroke-width ~8, no fill) in stroke order.
           Each stroke should be a separate <path> element.
           Add data-stroke-index="1", data-stroke-index="2" etc.

           Example stroke:
           <path
             data-stroke-index="1"
             d="M 180,120 C 200,100 280,140 300,200"
             fill="none"
             stroke="#e63946"
             stroke-width="8"
             stroke-linecap="round"
             stroke-linejoin="round"
           />
           ============================================================ -->
      <g
        id="strokes"
        fill="none"
        stroke="#e63946"
        stroke-width="8"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <!-- Draw strokes here, one <path> per stroke, in order -->
      </g>

    </svg>
  SVG

  [fname, svg]
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

force = ARGV.include?('--force') || ARGV.include?('-f')

FileUtils.mkdir_p(OUTPUT_DIR)

total = CHARACTERS.length
puts "Generating #{total} SVG templates in #{OUTPUT_DIR}/"
puts "(Reading character data from #{JSON_PATH})"
puts "Mode: #{force ? 'overwrite all' : 'skip existing (use --force to overwrite)'}"
puts

phase_names = {
  1 => "Basic Consonants",
  2 => "Vowel Components",
  3 => "Tone Marks",
  4 => "Numerals",
  5 => "Ligatures & Rare Forms"
}

current_phase = nil
count = 0
skipped = 0

CHARACTERS.each do |entry|
  phase = entry[:phase]
  order = entry[:order]
  codepoint = entry[:codepoint]

  if phase != current_phase
    current_phase = phase
    puts "--- Phase #{phase}: #{phase_names[phase]} ---"
  end

  fname, svg = generate_svg(entry)
  path = File.join(OUTPUT_DIR, fname)

  char = char_from_codepoint(codepoint)
  label = entry[:letter_name_romanized] || entry[:name]
  meaning = entry[:acrophonical_meaning] ? " (#{entry[:acrophonical_meaning]})" : ""

  if File.exist?(path) && !force
    puts "  #{format('%02d_%02d', phase, order)}  #{char}  #{format('U+%04X', codepoint)}  #{label}#{meaning}  [SKIPPED]"
    skipped += 1
  else
    File.write(path, svg, encoding: 'UTF-8')
    puts "  #{format('%02d_%02d', phase, order)}  #{char}  #{format('U+%04X', codepoint)}  #{label}#{meaning}"
    count += 1
  end
end

puts
puts "Done. #{count} files written, #{skipped} skipped in #{OUTPUT_DIR}/"
puts
puts "Next steps:"
puts "  1. Install Noto Lao font so the reference glyphs render correctly"
puts "  2. Open each SVG in Inkscape (or similar)"
puts "  3. Lock the 'reference' layer"
puts "  4. Draw center-line strokes in the 'strokes' layer, one <path> per stroke, in order"
puts "  5. Add data-stroke-index attributes to each path"
puts "  6. Update stroke-count in <metadata> and data-stroke-count on the root <svg>"
