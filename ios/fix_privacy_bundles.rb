#!/usr/bin/env ruby
# frozen_string_literal: true

# CRITICAL FIX: Remove privacy bundle dependencies that cause build failures
# This script fixes the Xcode 15+ privacy bundle issue with Flutter plugins
# Run this after pod install: ruby ios/fix_privacy_bundles.rb

require 'xcodeproj'

def fix_privacy_bundles
  project_path = 'Runner.xcodeproj'
  
  unless File.exist?(project_path)
    puts "❌ Error: #{project_path} not found!"
    exit 1
  end
  
  project = Xcodeproj::Project.open(project_path)
  
  modified = false
  
  # Find and remove privacy bundle references
  project.targets.each do |target|
    next unless target.name == 'Runner'
    
    puts "🔍 Processing target: #{target.name}"
    
    # Remove privacy bundles from Copy Resources phase
    target.build_phases.each do |build_phase|
      if build_phase.is_a?(Xcodeproj::Project::Object::PBXResourcesBuildPhase) ||
         build_phase.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
        
        files_to_remove = []
        
        build_phase.files.each do |file|
          if file.display_name&.include?('privacy.bundle') ||
             file.file_ref&.path&.include?('privacy.bundle')
            puts "  ❌ Removing problematic privacy bundle: #{file.display_name || file.file_ref&.path}"
            files_to_remove << file
            modified = true
          end
        end
        
        files_to_remove.each { |file| build_phase.files.delete(file) }
      end

      if build_phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
        original_input_paths = (build_phase.input_paths || []).dup
        original_output_paths = (build_phase.output_paths || []).dup
        original_input_file_lists = (build_phase.input_file_list_paths || []).dup
        original_output_file_lists = (build_phase.output_file_list_paths || []).dup

        build_phase.input_paths = original_input_paths.reject do |p|
          p.include?('PrivacyInfo.xcprivacy') || p.match?(/privacy\.bundle/i) || p.match?(/_privacy/i)
        end
        build_phase.output_paths = original_output_paths.reject do |p|
          p.include?('PrivacyInfo.xcprivacy') || p.match?(/privacy\.bundle/i) || p.match?(/_privacy/i)
        end
        build_phase.input_file_list_paths = original_input_file_lists.reject do |p|
          p.include?('PrivacyInfo.xcprivacy') || p.match?(/privacy\.bundle/i) || p.match?(/_privacy/i)
        end
        build_phase.output_file_list_paths = original_output_file_lists.reject do |p|
          p.include?('PrivacyInfo.xcprivacy') || p.match?(/privacy\.bundle/i) || p.match?(/_privacy/i)
        end

        if build_phase.input_paths != original_input_paths ||
           build_phase.output_paths != original_output_paths ||
           build_phase.input_file_list_paths != original_input_file_lists ||
           build_phase.output_file_list_paths != original_output_file_lists
          modified = true
        end
      end
    end
    
    # Remove privacy bundle file references
    project.files.each do |file_ref|
      if file_ref.path&.include?('privacy.bundle')
        puts "  ❌ Removing file reference: #{file_ref.path}"
        file_ref.remove_from_project
        modified = true
      end
    end
  end

  support_files_dir = File.join(__dir__, 'Pods', 'Target Support Files')
  if Dir.exist?(support_files_dir)
    Dir.glob(File.join(support_files_dir, '**', '*.xcfilelist')).each do |file|
      begin
        original = File.read(file)
        filtered = original.lines.reject do |line|
          line.include?('PrivacyInfo.xcprivacy') || line.match?(/privacy\.bundle/i) || line.match?(/_privacy/i)
        end.join
        if filtered != original
          File.write(file, filtered)
          modified = true
        end
      rescue StandardError
      end
    end
  end
  
  if modified
    project.save
    puts "✅ Successfully removed privacy bundle dependencies!"
  else
    puts "ℹ️ No privacy bundle dependencies found to remove."
  end
  
rescue StandardError => e
  puts "❌ Error fixing privacy bundles: #{e.message}"
  puts e.backtrace
  exit 1
end

# Run if called directly
if __FILE__ == $PROGRAM_NAME
  Dir.chdir(File.dirname(__FILE__))
  fix_privacy_bundles
end
