#encoding: UTF-8
require_relative '../spec_helper'

module RemoteLoggerTest

  shared_examples_for 'Logger' do
    before(:each) do
      File.stub!(:new) { |name, mode, opts| @logfile_mock = StringIO.new('', mode) }
    end

    context ' by default' do
      it 'creates a subclass of Log4r logger with default name "RemoteLogger"' do
        logger = described_class.new
        logger.should be_a_kind_of Log4r::Logger
        logger.should == Log4r::Logger['RemoteLogger']
        logger.should == RemoteLogger::Logger['RemoteLogger']
      end

      it 'outputs log messages to IOstream(file) and stdout simultaneously' do
        outputters = described_class.new.outputters
        outputters.should have(2).outputters
        outputters.first.should be_an_instance_of Log4r::StdoutOutputter
        outputters.last.should be_an_instance_of Log4r::IOOutputter
      end

      it 'appends to logfile "remote.log" with Windows-1251(Cyrillic) encoding' do
        File.should_receive(:new) do |filename, mode, options|
          filename.should == "remote.log"
          mode.should =~ /^a:/
          mode.should =~ /(CP|cp)1251:/
        end
        logger = described_class.new
      end

      it 'writes to stdout with IBM-866(DOS-Cyrillic) encoding' do
        $stdout.should_receive(:set_encoding).with(/(CP|cp)866:/, hash_including(:undef))
        logger = described_class.new
      end

      it 'logs string messages using default pattern' do
        logger = described_class.new
        logger_should_log 'I %Y-%m-%d %H:%M:\d{2}.\d{3} - My message\n'
        logger.info 'My message'
      end

      it 'does not log logger creation announcement' do
        pending 'both @logfile_mock creation and announcement happens in sequence, impossible to set expectations'
        logger_should_not_log 'Logger created'
        logger = described_class.new
      end

      it 'replaces illegal chars in output codepages with ?' do
        pending 'Impossible to test without real files, since StringIO does not support :undef option'
        logger_should_log 'I %Y-%m-%d %H:%M:\d{2}.\d{3} - My ?? message\n'
        logger = described_class.new
        logger.info 'My 開始 message'
      end
    end

    context 'with options' do
      it 'accepts logger name with :name option' do
        logger = described_class.new :name=>'MyLogger'
        logger.should == Log4r::Logger['MyLogger']
        logger.should == RemoteLogger::Logger['MyLogger']
      end

      it 'accepts logfile name with :file_name option' do
        File.should_receive(:new).with('my_name.log', anything, anything)
        logger = described_class.new :file_name=>'my_name.log'
      end

      it 'accepts custom log pattern with :pattern option' do
        logger = described_class.new :pattern=>'%d %l %7.7m'
        logger_should_log '%Y-%m-%d %H:%M:\d{2}.\d{3} INFO My mess\n'
        logger.info 'My message'
      end

      it 'accepts custom date pattern with :date_pattern option' do
        logger = described_class.new :date_pattern=>'%m/%d/%y'
        logger_should_log 'I %m/%d/%y - My message\n'
        logger.info 'My message'
      end

      it 'accepts custom file encoding with :file_encoding option' do
        File.should_receive(:new).with(anything, /^a:CP866/, anything)
        logger = described_class.new :file_encoding=>'CP866'
      end

      it 'accepts custom stdout encoding with :stdout_encoding option' do
        $stdout.should_receive(:set_encoding).with(/CP1251/, hash_including(:undef))
        logger = described_class.new :stdout_encoding=>'CP1251'
      end

      it 'accepts custom outputters with :outputters option, replacing default outputters' do
        out_string = StringIO.new
        $stdout.should_not_receive(:set_encoding)
        File.should_not_receive(:new)
        logger = described_class.new :outputters=>Log4r::IOOutputter.new('errors', out_string)
        $stdout.should_not_receive(:print)
        out_string.should_receive(:print).with " INFO RemoteLogger: My message\n"
        logger.info 'My message'
      end

      it 'rewrites logfile with :trunc option' do
        File.should_receive(:new).with(anything, /^w:/, anything)
#         File.new(options[:file_name]||FILE_NAME, (options[:trunc] ? 'w:' : 'a:') +
#                   (options[:file_encoding]||FILE_ENCODING), :undef => options[:undef]||:replace)
        logger = described_class.new( trunc: true)
      end

      it 'specifies conversion replacement char with :replace option' do
        pending 'Impossible to test without real files, since StringIO does not support :undef option'
        File.should_receive(:new).with(anything, anything, hash_including(:replace))
#         File.new(options[:file_name]||FILE_NAME, (options[:trunc] ? 'w:' : 'a:') +
#                   (options[:file_encoding]||FILE_ENCODING), :undef => options[:undef]||:replace)
        logger = described_class.new
        #:replace=>'-'
        logger_should_log '%Y-%m-%d %H:%M:\d{2}.\d{3} INFO My -- message\n'
        logger.info 'My 開始 message'
        p @logfile_mock
      end

      it 'logs logger creation announcement with :verbose option' do
        pending 'both @logfile_mock creation and announcement happens in sequence, impossible to set expectations'
        logger_should_log 'Logger created'
        logger = described_class.new( verbose: true )
      end

    end
  end
end
