#!/usr/bin/env ruby
# generate_lao_svgs.rb
# Generates SVG template files for Lao character stroke order annotation.
# Each SVG contains:
#   - Embedded metadata (Unicode codepoint, name, phase, romanization, etc.)
#   - A locked reference layer showing the character in Noto Lao font
#   - An empty <g id="strokes"> layer where you draw center-line stroke paths
#
# Usage: ruby generate_lao_svgs.rb [output_dir]
# Default output dir: ./lao_svgs

require 'fileutils'

OUTPUT_DIR = ARGV[0] || './lao_svgs'
SVG_SIZE   = 512   # canvas px
FONT_SIZE  = 380   # character display size

# ---------------------------------------------------------------------------
# Character database
# Each entry: [phase, order_within_phase, codepoint, name, romanization, notes]
# Phase 1 = 27 basic consonants (traditional alphabet order)
# Phase 2 = vowel marks and vowel letters
# Phase 3 = tone marks
# Phase 4 = numerals
# Phase 5 = ligature consonants + rare letters
# ---------------------------------------------------------------------------

CHARACTERS = [

  # PHASE 1 — 27 Basic Consonants (ພະຍັນຊະນະ)
  # Ordered as taught in Lao schools: traditional alphabet order
  [1,  1, 0x0E81, "ko",         "k",    "mid class"],
  [1,  2, 0x0E82, "kho sung",   "kh",   "high class"],
  [1,  3, 0x0E84, "kho tam",    "kh",   "low class"],
  [1,  4, 0x0E87, "ngo",        "ng",   "low class"],
  [1,  5, 0x0E88, "cho",        "ch/j", "mid class"],
  [1,  6, 0x0E8A, "so tam",     "s",    "low class"],
  [1,  7, 0x0E8D, "nyo",        "ny",   "low class"],
  [1,  8, 0x0E94, "do",         "d",    "mid class"],
  [1,  9, 0x0E95, "to",         "t",    "mid class"],
  [1, 10, 0x0E96, "tho sung",   "th",   "high class"],
  [1, 11, 0x0E97, "tho tam",    "th",   "low class"],
  [1, 12, 0x0E99, "no",         "n",    "low class"],
  [1, 13, 0x0E9A, "bo",         "b",    "mid class"],
  [1, 14, 0x0E9B, "po",         "p",    "mid class"],
  [1, 15, 0x0E9C, "pho sung",   "ph",   "high class"],
  [1, 16, 0x0E9D, "fo tam",     "f",    "high class"],
  [1, 17, 0x0E9E, "pho tam",    "ph",   "low class"],
  [1, 18, 0x0E9F, "fo sung",    "f",    "low class"],
  [1, 19, 0x0EA1, "mo",         "m",    "low class"],
  [1, 20, 0x0EA2, "yo",         "y",    "low class"],
  [1, 21, 0x0EA3, "lo ling",    "r/l",  "low class; rare, re-added to alphabet"],
  [1, 22, 0x0EA5, "lo loot",    "l",    "low class"],
  [1, 23, 0x0EA7, "wo",         "w/v",  "low class"],
  [1, 24, 0x0EAB, "ho sung",    "h",    "high class"],
  [1, 25, 0x0EAD, "o",          "-",    "mid class; glottal stop / vowel anchor"],
  [1, 26, 0x0EAE, "ho tam",     "h",    "low class"],
  [1, 27, 0x0EAF, "ellipsis",   "-",    "Lao ellipsis / paiyap punctuation mark"],

  # PHASE 2 — Vowel Components
  # Teaching order: above-consonant marks first (simplest placement),
  # then below, then pre-base (before consonant), then post-base letters,
  # then the ອ-based vowel letters which stand alone or after consonant.
  # Combining marks (U+0EB4..U+0EBC) are diacritics; spacing vowel letters
  # (U+0EC0..U+0EC4, U+0EAD, U+0EB2, U+0EB3, U+0EBB, U+0EBC) are standalone.

  # Above-consonant combining marks
  [2,  1, 0x0EB4, "sara i",        "i",    "short vowel; above consonant"],
  [2,  2, 0x0EB5, "sara ii",       "ii",   "long vowel; above consonant"],
  [2,  3, 0x0EB6, "sara u",        "ue",   "short vowel; above consonant"],
  [2,  4, 0x0EB7, "sara uu",       "uee",  "long vowel; above consonant"],
  [2,  5, 0x0EB8, "sara u (low)",  "u",    "short vowel; below consonant"],
  [2,  6, 0x0EB9, "sara uu (low)", "uu",   "long vowel; below consonant"],
  [2,  7, 0x0EBB, "mai kon",       "o",    "vowel modifier; above consonant"],
  [2,  8, 0x0EBC, "semivowel lo",  "l",    "subjoined; below consonant"],

  # Pre-base vowel letters (written before the consonant)
  [2,  9, 0x0EC0, "sara e",        "e",    "pre-base; long vowel"],
  [2, 10, 0x0EC1, "sara ae",       "ae",   "pre-base; long vowel"],
  [2, 11, 0x0EC2, "sara o",        "o",    "pre-base; long vowel"],
  [2, 12, 0x0EC3, "sara ai mak muan", "ai","pre-base"],
  [2, 13, 0x0EC4, "sara ai mak mai",  "ai","pre-base"],

  # Post-base / following vowel letters
  [2, 14, 0x0EB2, "sara aa",       "aa",   "long vowel; follows consonant"],
  [2, 15, 0x0EB3, "sara am",       "am",   "vowel + nasal; follows consonant"],

  # PHASE 3 — Tone Marks (ວັນນະຍຸດ)
  # mai ek and mai tho are the two everyday marks; mai tri and mai jattawa
  # are used for loanwords and special cases.
  [3,  1, 0x0EC8, "mai ek",        "1",    "most common tone mark"],
  [3,  2, 0x0EC9, "mai tho",       "2",    "second most common tone mark"],
  [3,  3, 0x0ECA, "mai tri",       "3",    "used for loanwords"],
  [3,  4, 0x0ECB, "mai jattawa",   "4",    "used for loanwords"],

  # PHASE 4 — Lao Numerals (໐–໙)
  [4,  1, 0x0ED0, "zero",   "0", ""],
  [4,  2, 0x0ED1, "one",    "1", ""],
  [4,  3, 0x0ED2, "two",    "2", ""],
  [4,  4, 0x0ED3, "three",  "3", ""],
  [4,  5, 0x0ED4, "four",   "4", ""],
  [4,  6, 0x0ED5, "five",   "5", ""],
  [4,  7, 0x0ED6, "six",    "6", ""],
  [4,  8, 0x0ED7, "seven",  "7", ""],
  [4,  9, 0x0ED8, "eight",  "8", ""],
  [4, 10, 0x0ED9, "nine",   "9", ""],

  # PHASE 5 — Ligature Consonants & Rare Forms
  # 0xEDC = HO NO (ໜ), 0xEDD = HO MO (ໝ) — Unicode ligatures for ຫນ and ຫມ
  # 0xEA3 lo ling already included in phase 1 as #21 (flagged rare there)
  [5,  1, 0x0EDC, "ho no",  "hn", "ligature of ຫ+ນ; high-class variant"],
  [5,  2, 0x0EDD, "ho mo",  "hm", "ligature of ຫ+ມ; high-class variant"],

].freeze

# ---------------------------------------------------------------------------
# SVG generation
# ---------------------------------------------------------------------------

def escape_xml(str)
  str.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;').gsub('"','&quot;').gsub("'",'&apos;')
end

def char_from_codepoint(cp)
  [cp].pack('U')
end

def filename(phase, order, name, codepoint)
  safe_name = name.gsub(/\s+/, '_').gsub(/[^a-z0-9_]/i, '')
  hex = format('U%04X', codepoint)
  format('%02d_%02d_%s_%s.svg', phase, order, safe_name, hex)
end

def generate_svg(phase, order, codepoint, name, romanization, notes)
  char   = char_from_codepoint(codepoint)
  hex    = format('U+%04X', codepoint)
  fname  = filename(phase, order, name, codepoint)
  size   = SVG_SIZE
  center = size / 2.0
  fs     = FONT_SIZE

  # Baseline offset: visually center the glyph.
  # For Lao glyphs, approximately 65% down from top works well as baseline.
  baseline_y = (size * 0.72).round

  svg = <<~SVG
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
      data-stroke-count=""
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
          <lao:notes>#{escape_xml(notes)}</lao:notes>
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
      <g id="reference" opacity="0.18" pointer-events="none">
        <text
          x="#{center}"
          y="#{baseline_y}"
          font-family="'Noto Lao UI', 'Noto Lao', 'Phetsarath OT', 'Saysettha OT', sans-serif"
          font-size="#{fs}"
          text-anchor="middle"
          fill="#0066cc"
        >#{escape_xml(char)}</text>
      </g>

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
        >#{escape_xml(char)}  #{hex}  #{escape_xml(name)}  /#{escape_xml(romanization)}/</text>
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

FileUtils.mkdir_p(OUTPUT_DIR)

total = CHARACTERS.length
puts "Generating #{total} SVG templates in #{OUTPUT_DIR}/"
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

CHARACTERS.each do |phase, order, codepoint, name, romanization, notes|
  if phase != current_phase
    current_phase = phase
    puts "--- Phase #{phase}: #{phase_names[phase]} ---"
  end

  fname, svg = generate_svg(phase, order, codepoint, name, romanization, notes)
  path = File.join(OUTPUT_DIR, fname)
  File.write(path, svg, encoding: 'UTF-8')

  char = char_from_codepoint(codepoint)
  puts "  #{format('%02d_%02d', phase, order)}  #{char}  #{format('U+%04X', codepoint)}  #{name}"
  count += 1
end

puts
puts "Done. #{count} files written to #{OUTPUT_DIR}/"
puts
puts "Next steps:"
puts "  1. Install Noto Lao font so the reference glyphs render correctly"
puts "  2. Open each SVG in Inkscape (or similar)"
puts "  3. Lock the 'reference' layer"
puts "  4. Draw center-line strokes in the 'strokes' layer, one <path> per stroke, in order"
puts "  5. Add data-stroke-index attributes to each path"
puts "  6. Update stroke-count in <metadata> and data-stroke-count on the root <svg>"
SVG
