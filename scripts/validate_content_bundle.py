#!/usr/bin/env python3
"""
Content Bundle Validator for Write Lao Vocabulary Feature.

This script validates the vocabulary content bundle before shipping:
- Validates JSON structure against schema
- Checks all referenced image files exist
- Checks all referenced audio files exist
- Validates character type tags
- Checks for dangling foreign keys
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple

# Configuration
CONTENT_FILE = "assets/vocab/content.json"
ASSETS_DIR = "assets/vocab"
MAX_BUNDLE_SIZE_MB = 150


def load_content(content_path: str) -> dict:
    """Load and parse the content JSON file."""
    with open(content_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def validate_schema(content: dict) -> List[str]:
    """Validate the content JSON against expected schema."""
    errors = []
    
    required_fields = ['version', 'language', 'units', 'lessons', 'words']
    for field in required_fields:
        if field not in content:
            errors.append(f"Missing required field: {field}")
    
    if 'units' in content and not isinstance(content['units'], list):
        errors.append("'units' must be a list")
    
    if 'lessons' in content and not isinstance(content['lessons'], list):
        errors.append("'lessons' must be a list")
    
    if 'words' in content and not isinstance(content['words'], list):
        errors.append("'words' must be a list")
    
    return errors


def validate_foreign_keys(content: dict) -> List[str]:
    """Check for dangling foreign keys."""
    errors = []
    
    # Collect all IDs
    unit_ids = {u['unit_id'] for u in content.get('units', [])}
    lesson_ids = {l['lesson_id'] for l in content.get('lessons', [])}
    word_ids = {w['word_id'] for w in content.get('words', [])}
    
    # Check unit -> lesson references
    for unit in content.get('units', []):
        for lesson_id in unit.get('lesson_ids', []):
            if lesson_id not in lesson_ids:
                errors.append(f"Unit {unit['unit_id']} references missing lesson: {lesson_id}")
    
    # Check lesson -> unit references
    for lesson in content.get('lessons', []):
        if lesson.get('unit_id') not in unit_ids:
            errors.append(f"Lesson {lesson['lesson_id']} references missing unit: {lesson.get('unit_id')}")
    
    # Check lesson -> word references
    for lesson in content.get('lessons', []):
        for word_id in lesson.get('new_word_ids', []) + lesson.get('review_word_ids', []):
            if word_id not in word_ids:
                errors.append(f"Lesson {lesson['lesson_id']} references missing word: {word_id}")
    
    return errors


def validate_character_types(content: dict) -> List[str]:
    """Validate that all characters have type tags."""
    errors = []
    valid_types = {'consonant', 'vowel', 'tone', 'final', 'other'}
    
    for word in content.get('words', []):
        for char in word.get('characters', []):
            char_type = char.get('type', '').lower()
            if char_type not in valid_types:
                errors.append(f"Word {word['word_id']} has invalid character type: {char_type}")
    
    return errors


def validate_assets(content: dict, assets_dir: str) -> List[str]:
    """Check that all referenced asset files exist."""
    errors = []
    warnings = []
    
    for word in content.get('words', []):
        word_id = word['word_id']
        
        # Check image
        image_path = word.get('image_path', '')
        if image_path:
            full_path = os.path.join(assets_dir, image_path)
            if not os.path.exists(full_path):
                errors.append(f"Missing image: {full_path}")
        
        # Check audio
        audio_path = word.get('audio_path', '')
        if audio_path:
            full_path = os.path.join(assets_dir, audio_path)
            if not os.path.exists(full_path):
                errors.append(f"Missing audio: {full_path}")
        
        # Check example audio
        for example in word.get('examples', []):
            ex_audio_path = example.get('audio_path', '')
            if ex_audio_path:
                full_path = os.path.join(assets_dir, ex_audio_path)
                if not os.path.exists(full_path):
                    errors.append(f"Missing example audio: {full_path}")
    
    return errors


def calculate_bundle_size(assets_dir: str) -> Tuple[float, List[str]]:
    """Calculate total bundle size in MB."""
    total_bytes = 0
    warnings = []
    
    if not os.path.exists(assets_dir):
        warnings.append(f"Assets directory not found: {assets_dir}")
        return 0, warnings
    
    for root, dirs, files in os.walk(assets_dir):
        for file in files:
            file_path = os.path.join(root, file)
            total_bytes += os.path.getsize(file_path)
    
    size_mb = total_bytes / (1024 * 1024)
    
    if size_mb > MAX_BUNDLE_SIZE_MB:
        warnings.append(f"Bundle size ({size_mb:.1f} MB) exceeds target ({MAX_BUNDLE_SIZE_MB} MB)")
    
    return size_mb, warnings


def print_report(errors: List[str], warnings: List[str], size_mb: float):
    """Print validation report."""
    print("\n" + "=" * 50)
    print("CONTENT BUNDLE VALIDATION REPORT")
    print("=" * 50)
    
    if errors:
        print(f"\n❌ ERRORS ({len(errors)}):")
        for error in errors:
            print(f"  - {error}")
    
    if warnings:
        print(f"\n⚠️  WARNINGS ({len(warnings)}):")
        for warning in warnings:
            print(f"  - {warning}")
    
    print(f"\n📦 Bundle Size: {size_mb:.1f} MB")
    
    if not errors:
        print("\n✅ VALIDATION PASSED")
        return 0
    else:
        print(f"\n❌ VALIDATION FAILED ({len(errors)} errors)")
        return 1


def main():
    # Check if content file exists
    if not os.path.exists(CONTENT_FILE):
        print(f"❌ Content file not found: {CONTENT_FILE}")
        print("Run this script from the project root directory.")
        return 1
    
    print(f"Loading content from: {CONTENT_FILE}")
    
    try:
        content = load_content(CONTENT_FILE)
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON: {e}")
        return 1
    
    print(f"Loaded {len(content.get('units', []))} units, "
          f"{len(content.get('lessons', []))} lessons, "
          f"{len(content.get('words', []))} words")
    
    # Run validations
    all_errors = []
    all_warnings = []
    
    all_errors.extend(validate_schema(content))
    all_errors.extend(validate_foreign_keys(content))
    all_errors.extend(validate_character_types(content))
    all_errors.extend(validate_assets(content, ASSETS_DIR))
    
    size_mb, warnings = calculate_bundle_size(ASSETS_DIR)
    all_warnings.extend(warnings)
    
    return print_report(all_errors, all_warnings, size_mb)


if __name__ == "__main__":
    sys.exit(main())
