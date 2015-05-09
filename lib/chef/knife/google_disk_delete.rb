# Copyright 2015 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'chef/knife/google_base'

class Chef
  class Knife
    class GoogleDiskDelete < Knife

      include Knife::GoogleBase

      banner "knife google disk delete NAME (options)"

      option :gce_zone,
        :short => "-Z ZONE",
        :long => "--gce-zone ZONE",
        :description => "The Zone for this disk",
        :proc => Proc.new { |key| Chef::Config[:knife][:gce_zone] = key }

      def run
        $stdout.sync = true
        unless @name_args.size > 0
          ui.error("Please provide the name of the disk to be deleted")
          raise
        end
        begin
          ui.confirm("Delete the disk '#{config[:zone]}:#{@name_args.first}'")
          result = client.execute(
            :api_method => compute.disks.delete,
            :parameters => {:project => config[:gce_project], :zone => config[:gce_zone], :disk => @name_args.first})
          ui.warn("Disk '#{config[:zone]}:#{@name_args.first}' deleted") if result.status == 200
        rescue
          body = MultiJson.load(result.body, :symbolize_keys => true)
          ui.error("#{body[:error][:message]}")
          raise
        end
      end

    end
  end
end
