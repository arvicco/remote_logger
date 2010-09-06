#encoding: UTF-8
require_relative '../spec_helper'
require_relative 'shared_spec'

module RemoteLoggerTest
  describe RemoteLogger::DrbLogger do
    spec { use { include RemoteLogger } }

    context 'creating Drb logger' do
      spec { pending; use { RemoteLogger.start_drb_logger(name = 'RemoteLogger', options = {}) } }

      it_should_behave_like 'Logger'

      it 'instantiates drb logger service'

    end
  end
end

