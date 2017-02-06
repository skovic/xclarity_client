# this is basically copied from miq_report_result/purging.rb
describe DriftState do
  context "::Purging" do
    before(:each) do
      @vmdb_config = {
        :drift_states => {
          :history => {
            :keep_drift_states => "6.months",
            :purge_window_size => 100
          }
        }
      }
      stub_server_configuration(@vmdb_config)

      @rr1 = [
        FactoryGirl.create(:drift_state, :resource_type => 'VmOrTemplate', :resource_id => 1, :timestamp => (6.months + 1.days).to_i.seconds.ago.utc),
        FactoryGirl.create(:drift_state, :resource_type => 'VmOrTemplate', :resource_id => 1, :timestamp => (6.months - 1.days).to_i.seconds.ago.utc)
      ]
      @rr2 = [
        FactoryGirl.create(:drift_state, :resource_type => 'VmOrTemplate', :resource_id => 2, :timestamp => (6.months + 2.days).to_i.seconds.ago.utc),
        FactoryGirl.create(:drift_state, :resource_type => 'VmOrTemplate', :resource_id => 2, :timestamp => (6.months + 1.days).to_i.seconds.ago.utc),
        FactoryGirl.create(:drift_state, :resource_type => 'VmOrTemplate', :resource_id => 2, :timestamp => (6.months - 1.days).to_i.seconds.ago.utc)
      ]
      @rr_orphaned = [
        FactoryGirl.create(:drift_state, :resource_type => 'VmOrTemplate', :resource_id => nil, :timestamp => (6.months - 1.days).to_i.seconds.ago.utc)
      ]
    end

    it "#purge_timer" do
      EvmSpecHelper.create_guid_miq_server_zone

      Timecop.freeze(Time.now) do
        described_class.purge_timer

        q = MiqQueue.all
        expect(q.length).to eq(1)
        expect(q.first).to have_attributes(
          :class_name  => described_class.name,
          :method_name => "purge"
        )
        expect(q.first.args[0]).to eq(:date)
        expect(q.first.args[1]).to be_same_time_as 6.months.to_i.seconds.ago.utc
      end
    end

    context "#purge_queue" do
      before(:each) do
        EvmSpecHelper.create_guid_miq_server_zone
        described_class.purge_queue(:remaining, 1)
      end

      it "with nothing in the queue" do
        q = MiqQueue.all
        expect(q.length).to eq(1)
        expect(q.first).to have_attributes(
          :class_name  => described_class.name,
          :method_name => "purge",
          :args        => [:remaining, 1]
        )
      end

      it "with item already in the queue" do
        described_class.purge_queue(:remaining, 2)

        q = MiqQueue.all
        expect(q.length).to eq(1)
        expect(q.first).to have_attributes(
          :class_name  => described_class.name,
          :method_name => "purge",
          :args        => [:remaining, 2]
        )
      end
    end

    context "#purge_count" do
      it "by remaining" do
        expect(described_class.purge_count(:remaining, 1)).to eq(3)
      end

      it "by date" do
        expect(described_class.purge_count(:date, 6.months.to_i.seconds.ago.utc)).to eq(3)
      end
    end

    context "#purge" do
      it "by remaining" do
        described_class.purge(:remaining, 1)
        expect(described_class.where(:resource_id => 1)).to eq([@rr1.last])
        expect(described_class.where(:resource_id => 2)).to eq([@rr2.last])
        expect(described_class.where(:resource_id => nil)).to eq(@rr_orphaned)
      end

      it "by date" do
        described_class.purge(:date, 6.months.to_i.seconds.ago.utc)
        expect(described_class.where(:resource_id => 1)).to eq([@rr1.last])
        expect(described_class.where(:resource_id => 2)).to eq([@rr2.last])
        expect(described_class.where(:resource_id => nil)).to eq(@rr_orphaned)
      end
    end
  end
end
