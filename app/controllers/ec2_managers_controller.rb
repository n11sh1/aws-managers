class Ec2ManagersController < ApplicationController

  before_action :initialize, only: [:index, :start_instance, :stop_instance]

  def index
    getInstances
  end

  def start_instance
    param = params[:instance_id]
    getInstanceIds(param, 'stopped')

    if @instanceIds.length > 0
      begin
        @ec2.start_instances(instance_ids: @instanceIds)
        @ec2.wait_until(:instance_running,  instance_ids: @instanceIds)
        redirect_to ec2_managers_path
      rescue Aws::Waiters::Errors::WaiterFailed => error
        @errorMsg = 'Instance Running Failure!'
        getInstances
        render :index
      end
    else
      redirect_to ec2_managers_path
    end
  end

  def stop_instance
    param = params[:instance_id]
    getInstanceIds(param, 'running')

    if @instanceIds.length > 0
      begin
        @ec2.stop_instances(instance_ids: @instanceIds)
        @ec2.wait_until(:instance_stopped,  instance_ids: @instanceIds)
        redirect_to ec2_managers_path
      rescue Aws::Waiters::Errors::WaiterFailed => error
        @errorMsg = 'Instance Stopped Failure!'
        getInstances
        render :index
      end
    else
      redirect_to ec2_managers_path
    end
  end

  private
    def initialize
      @ec2 = Aws::EC2::Client.new(
        region:'xxxxx',
        access_key_id: 'xxxxx',
        secret_access_key: 'xxxxx'
      )
    end

    def getInstances(instance_state_name=nil)
      if instance_state_name.nil?
        @resp = @ec2.describe_instances(
          filters:[{ name: 'tag-key', values: ['ManagementFlag'] }]
        )
      else
        @resp = @ec2.describe_instances(
          filters:[
            { name: 'instance-state-name', values: [instance_state_name]},
            { name: 'tag-key', values: ['ManagementFlag'] }
          ]
        )
      end
    end

    def getInstanceIds(type, instance_state_name)
      @instanceIds = Array.new()

      if 'all' == type
        getInstances(instance_state_name)
        @resp.reservations.each do |reservation|
          reservation.instances.each do |instance|
            @instanceIds.push(instance.instance_id)
          end
        end
      else
        @instanceIds.push(type)
      end
    end
end
