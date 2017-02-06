module MiqAeServiceContainerSpec
  describe MiqAeMethodService::MiqAeServiceContainerQuota do
    it "#ext_management_system" do
      expect(described_class.instance_methods).to include(:ext_management_system)
    end

    it "#container_project" do
      expect(described_class.instance_methods).to include(:container_project)
    end

    it "#container_quota_items" do
      expect(described_class.instance_methods).to include(:container_quota_items)
    end
  end
end
