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
      expect(subject['mnp_data']['src_trunk']).to eq('NEXMO_C01')
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
      expect(subject['smpp']['src']).to eq('4915173041787')
      expect(subject['smpp']['src_ton']).to eq('1')
      expect(subject['smpp']['src_npi']).to eq('1')
      expect(subject['smpp']['dst']).to eq('car2go')
      expect(subject['smpp']['dst_ton']).to eq('5')
      expect(subject['smpp']['dst_npi']).to eq('0')
      expect(subject['smpp']['class']).to eq('4')
      expect(subject['smpp']['priority']).to eq('0')
      expect(subject['smpp']['registered_dlr']).to eq('0')
      expect(subject['smpp']['data_length']).to eq('121')
      expect(subject['smpp']['data_coding']).to eq('0')
      expect(subject['smpp']).to include("dlr")
      expect(subject['smpp']['dlr']).to eq('id:10f6e4bda0c sub:001 dlvrd:001 submit date:1512101615 done date:1512101615 stat:DELIVRD err:0 text:Vielen Dank. Ihre Mi')
      #expect(subject['smpp']['dlr']['id']).to eq('10f6e4bda0c')
      #expect(subject['smpp']['dlr']['sub']).to eq('001')
      #expect(subject['smpp']['dlr']['dlvrd']).to eq('001')
      #expect(subject['smpp']['dlr']['submit_date']).to eq('1512101615')
      #expect(subject['smpp']['dlr']['done_date']).to eq('1512101615')
      #expect(subject['smpp']['dlr']['stat']).to eq('DELIVRD')
      #expect(subject['smpp']['dlr']['err']).to eq('0')
      #expect(subject['smpp']['dlr']['text']).to eq('Vielen Dank. Ihre Mi')
      expect(subject['smpp']['data_hex']).to eq('69643A3130663665346264613063207375623A30303120646C7672643A303031207375626D697420646174653A3135313231303136313520646F6E6520646174653A3135313231303136313520737461743A44454C49565244206572723A3020746578743A5669656C656E2044616E6B2E2049687265204D69')
    end
  end

  describe "deliver sm skip fields" do
    let(:config) do <<-CONFIG
      filter {
        smpp {
          remove_field => ["[smpp][data_hex]", "[smpp][record_type]"]
        }
      }
    CONFIG
    end

    sample("payload" => "000000c200000005000000000000f0730001013439313531373330343137383700050063617232676f000400000000000000007969643a3130663665346264613063207375623a30303120646c7672643a303031207375626d697420646174653a3135313231303136313520646f6e6520646174653a3135313231303136313520737461743a44454c49565244206572723a3020746578743a5669656c656e2044616e6b2e2049687265204d690427000102001e000c313066366534626461306300") do
      expect(subject).to include("smpp")
      expect(subject['smpp']).not_to include('record_type')
      expect(subject['smpp']['src']).to eq('4915173041787')
      expect(subject['smpp']['src_ton']).to eq('1')
      expect(subject['smpp']['src_npi']).to eq('1')
      expect(subject['smpp']['dst']).to eq('car2go')
      expect(subject['smpp']['dst_ton']).to eq('5')
      expect(subject['smpp']['dst_npi']).to eq('0')
      expect(subject['smpp']['class']).to eq('4')
      expect(subject['smpp']['priority']).to eq('0')
      expect(subject['smpp']['registered_dlr']).to eq('0')
      expect(subject['smpp']['data_length']).to eq('121')
      expect(subject['smpp']['data_coding']).to eq('0')
      expect(subject['smpp']).to include("dlr")
      expect(subject['smpp']['dlr']).to eq('id:10f6e4bda0c sub:001 dlvrd:001 submit date:1512101615 done date:1512101615 stat:DELIVRD err:0 text:Vielen Dank. Ihre Mi')
      expect(subject['smpp']).not_to include('data_hex')
    end
  end

  describe "deliver sm in with empty body" do
    let(:config) do <<-CONFIG
      filter {
        smpp {
        }
      }
    CONFIG
    end

    sample("payload" => "0000004e00000005000000000000009c0001013438353035393533343334000500494e464f20534d530004000000000000000000001e001138334642463841393030303030303030000427000102") do
      expect(subject).to include("smpp")
      expect(subject['smpp']['record_type']).to eq('DeliverSM')
      expect(subject['smpp']['src']).to eq('48505953434')
      expect(subject['smpp']['src_ton']).to eq('1')
      expect(subject['smpp']['src_npi']).to eq('1')
      expect(subject['smpp']['dst']).to eq('INFO SMS')
      expect(subject['smpp']['dst_ton']).to eq('5')
      expect(subject['smpp']['dst_npi']).to eq('0')
      expect(subject['smpp']['class']).to eq('4')
      expect(subject['smpp']['priority']).to eq('0')
      expect(subject['smpp']['registered_dlr']).to eq('0')
      expect(subject['smpp']['data_length']).to eq('0')
      expect(subject['smpp']['data_coding']).to eq('0')
      expect(subject['smpp']['data_hex']).to eq('')
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
      expect(subject['mnp']['src_trunk']).to eq('NEXMO_C01')
      expect(subject['mnp']['msisdn']).to eq('4915173041787')
      expect(subject['mnp']['destination_context']).to eq('NEUSTAR_M01')
    end
  end
  
end
