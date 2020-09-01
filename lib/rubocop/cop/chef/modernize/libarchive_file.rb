# frozen_string_literal: true
#
# Copyright:: 2019-2020, Chef Software Inc.
# Author:: Tim Smith (<tsmith@chef.io>)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module RuboCop
  module Cop
    module Chef
      module ChefModernize
        # Use the archive_file resource built into Chef Infra Client 15+ instead of the libarchive_file resource.
        #
        # @example
        #
        #   # bad
        #   libarchive_file "C:\file.zip" do
        #     path 'C:\expand_here'
        #   end
        #
        #   # good
        #   archive_file "C:\file.zip" do
        #     path 'C:\expand_here'
        #   end
        #
        class LibarchiveFileResource < Base
          extend TargetChefVersion
          extend AutoCorrector

          minimum_target_chef_version '15.0'

          MSG = 'Use the archive_file resource built into Chef Infra Client 15+ instead of the libarchive file resource'

          def_node_matcher :notification_property?, <<-PATTERN
            (send nil? {:notifies :subscribes} (sym _) $(...) (sym _))
          PATTERN

          def on_send(node)
            # The need for this goes away once https://github.com/rubocop-hq/rubocop/pull/8365 is pulled into Cookstyle
            if node.method_name == :libarchive_file
              add_offense(node, message: MSG, severity: :refactor) do |corrector|
                corrector.replace(node.loc.expression, node.source.gsub('libarchive_file', 'archive_file'))
              end
            end

            notification_property?(node) do |val|
              next unless val.str_content&.start_with?('libarchive_file')
              add_offense(val, message: MSG, severity: :refactor) do |corrector|
                corrector.replace(node.loc.expression, node.source.gsub('libarchive_file', 'archive_file'))
              end
            end
          end
        end
      end
    end
  end
end
