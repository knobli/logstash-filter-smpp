# encoding: utf-8
require 'spec_helper'
require "logstash/filters/smpp"

describe LogStash::Filters::Smpp do
  describe "defaults" do
    let(:config) do <<-CONFIG
      filter {
        smpp {
        }
      }
    CONFIG
    end

    sample("payload" => "000000c200000005000000000000f0730001013439313531373330343137383700050063617232676f000400000000000000007969643a3130663665346264613063207375623a30303120646c7672643a303031207375626d697420646174653a3135313231303136313520646f6e6520646174653a3135313231303136313520737461743a44454c49565244206572723a3020746578743a5669656c656e2044616e6b2e2049687265204d690427000102001e000c313066366534626461306300") do
      expect(subject).to include("smpp")
      expect(subject['smpp']['record_type']).to eq('DeliverSM')
    end
  end

  describe "when specifying source" do
    let(:config) do <<-CONFIG
      filter {
        smpp {
          source => "smpp_payload"
        }
      }
    CONFIG
    end

    sample("smpp_payload" => "000000c200000005000000000000f0730001013439313531373330343137383700050063617232676f000400000000000000007969643a3130663665346264613063207375623a30303120646c7672643a303031207375626d697420646174653a3135313231303136313520646f6e6520646174653a3135313231303136313520737461743a44454c49565244206572723a3020746578743a5669656c656e2044616e6b2e2049687265204d690427000102001e000c313066366534626461306300") do
      expect(subject).to include("smpp")
      expect(subject['smpp']['record_type']).to eq('DeliverSM')
    end
  end

  describe "when specifying smpp_target" do
    let(:config) do <<-CONFIG
      filter {
        smpp {
          smpp_target => "smpp_data"
        }
      }
    CONFIG
    end

    sample("payload" => "000000c200000005000000000000f0730001013439313531373330343137383700050063617232676f000400000000000000007969643a3130663665346264613063207375623a30303120646c7672643a303031207375626d697420646174653a3135313231303136313520646f6e6520646174653a3135313231303136313520737461743a44454c49565244206572723a3020746578743a5669656c656e2044616e6b2e2049687265204d690427000102001e000c313066366534626461306300") do
      expect(subject).to include("smpp_data")
      expect(subject['smpp_data']['record_type']).to eq('DeliverSM')
    end
  end

  describe "when specifying mnp_target" do
    let(:config) do <<-CONFIG
      filter {
        smpp {
          mnp_target => "mnp_data"
        }
      }
    CONFIG
    end

    sample("payload" => "53697a653a3335330a53657175656e636553746174653a424547494e0a46726f6d3a3137322e31382e31362e32370a546f3a3137322e31382e31362e34350a43616c6c2d49443a36306630616566623739383434333233393932663436633066313338653533300a56657273696f6e3a310a53657175656e63654e6f3a310a4d6574686f643a4d4e500a5372635472756e6b3a4e45584d4f5f4330310a547970653a34310a4d534953444e3a343931353137333034313738370a53657373696f6e2d49443a64356333363566353065653634663961623361653733343739623537383337330a46726f6d506f72743a33333030380a546f506f72743a33333030330a44657374696e6174696f6e436f6e746578743a4e4555535441525f4d30310a536f75726365436f6e746578743a7a6830312d6875622d30310a475549443a62636434383564326466663934376266616438343230313761383664636136340a") do
      expect(subject).to include("mnp_data")
      expect(subject['mnp_data']['size']).to eq('353')
    end
  end

  describe "when remove source" do
    let(:config) do <<-CONFIG
      filter {
        smpp {
          remove_field => ["payload"]
        }
      }
    CONFIG
    end

    sample("payload" => "000000c200000005000000000000f0730001013439313531373330343137383700050063617232676f000400000000000000007969643a3130663665346264613063207375623a30303120646c7672643a303031207375626d697420646174653a3135313231303136313520646f6e6520646174653a3135313231303136313520737461743a44454c49565244206572723a3020746578743a5669656c656e2044616e6b2e2049687265204d690427000102001e000c313066366534626461306300") do
      expect(subject).not_to include("payload")
    end
  end

  describe "deliver sm in parsing" do
    let(:config) do <<-CONFIG
      filter {
        smpp {
        }
      }
    CONFIG
    end

    sample("payload" => "000000c200000005000000000000f0730001013439313531373330343137383700050063617232676f000400000000000000007969643a3130663665346264613063207375623a30303120646c7672643a303031207375626d697420646174653a3135313231303136313520646f6e6520646174653a3135313231303136313520737461743a44454c49565244206572723a3020746578743a5669656c656e2044616e6b2e2049687265204d690427000102001e000c313066366534626461306300") do
      expect(subject).to include("smpp")
      expect(subject['smpp']['record_type']).to eq('DeliverSM')
      expect(subject['smpp']['source']).to eq('4915173041787')
      expect(subject['smpp']['source_ton']).to eq('1')
      expect(subject['smpp']['source_ton_value']).to eq('International')
      expect(subject['smpp']['source_npi']).to eq('1')
      expect(subject['smpp']['source_npi_value']).to eq('ISDN (E163/E164)')
      expect(subject['smpp']['destination']).to eq('car2go')
      expect(subject['smpp']['destination_ton']).to eq('5')
      expect(subject['smpp']['destination_ton_value']).to eq('Alphanumeric')
      expect(subject['smpp']['destination_npi']).to eq('0')
      expect(subject['smpp']['destination_npi_value']).to eq('Unknown')
      expect(subject['smpp']['class']).to eq('4')
      expect(subject['smpp']['class_value']).to eq('SMSC Delivery Receipt')
      expect(subject['smpp']['priority']).to eq('0')
      expect(subject['smpp']['registered_dlr']).to eq('0')
      expect(subject['smpp']['registered_dlr_value']).to eq('Not Requested')
      expect(subject['smpp']['data_length']).to eq('121')
      expect(subject['smpp']['data_coding']).to eq('0')
      expect(subject['smpp']['data_coding_value']).to eq('SMSC Default Alphabet')
      expect(subject['smpp']['data']).to eq('id:10f6e4bda0c sub:001 dlvrd:001 submit date:1512101615 done date:1512101615 stat:DELIVRD err:0 text:Vielen Dank. Ihre Mi')
    end
  end

  describe "mnp lookup parsing" do
    let(:config) do <<-CONFIG
      filter {
        smpp {
        }
      }
    CONFIG
    end

    sample("payload" => "53697a653a3335330a53657175656e636553746174653a424547494e0a46726f6d3a3137322e31382e31362e32370a546f3a3137322e31382e31362e34350a43616c6c2d49443a36306630616566623739383434333233393932663436633066313338653533300a56657273696f6e3a310a53657175656e63654e6f3a310a4d6574686f643a4d4e500a5372635472756e6b3a4e45584d4f5f4330310a547970653a34310a4d534953444e3a343931353137333034313738370a53657373696f6e2d49443a64356333363566353065653634663961623361653733343739623537383337330a46726f6d506f72743a33333030380a546f506f72743a33333030330a44657374696e6174696f6e436f6e746578743a4e4555535441525f4d30310a536f75726365436f6e746578743a7a6830312d6875622d30310a475549443a62636434383564326466663934376266616438343230313761383664636136340a") do
      expect(subject).to include("mnp")
      expect(subject['mnp']['size']).to eq('353')
      expect(subject['mnp']['sequence_state']).to eq('BEGIN')
      expect(subject['mnp']['from']).to eq('172.18.16.27')
      expect(subject['mnp']['to']).to eq('172.18.16.45')
      expect(subject['mnp']['call_id']).to eq('60f0aefb79844323992f46c0f138e530')
      expect(subject['mnp']['version']).to eq('1')
      expect(subject['mnp']['sequence_no']).to eq('1')
      expect(subject['mnp']['method']).to eq('MNP')
      expect(subject['mnp']['src_trunk']).to eq('NEXMO_C01')
      expect(subject['mnp']['type']).to eq('41')
      expect(subject['mnp']['msisdn']).to eq('4915173041787')
      expect(subject['mnp']['session_id']).to eq('d5c365f50ee64f9ab3ae73479b578373')
      expect(subject['mnp']['from_port']).to eq('33008')
      expect(subject['mnp']['to_port']).to eq('33003')
      expect(subject['mnp']['destination_context']).to eq('NEUSTAR_M01')
      expect(subject['mnp']['source_context']).to eq('zh01-hub-01')
      expect(subject['mnp']['guid']).to eq('bcd485d2dff947bfad842017a86dca64')
    end
  end
  
end
