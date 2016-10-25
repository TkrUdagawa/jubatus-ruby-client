#!/usr/bin/env ruby

require 'test/unit'

require 'json'

require 'jubatus/clustering/client'
require 'jubatus_test/test_util'

class ClusteringTest < Test::Unit::TestCase
  HOST = "127.0.0.1"
  PORT = 23008
  TIMEOUT = 10

  def setup
    @config = {
      "method" => "kmeans",
      "converter" => {
        "string_filter_types" => {},
        "string_filter_rules" => [],
        "num_filter_types" => {},
        "num_filter_rules" => [],
        "string_types" => {},
        "string_rules" => [
                           { "key" => "*", "type" => "str", "sample_weight" => "bin", "global_weight" => "bin" }
                          ],
        "num_types" => {},
        "num_rules" => [
                        { "key" => "*", "type" => "num" }
                       ]
      },
      "parameter" => {
        "k" => 10,
        "seed" => 0
      },
      "compressor_method" => "simple",
      "compressor_parameter" => {
        "bucket_size" => 3
      }
    }

    TestUtil.write_file("config_clustering.json", @config.to_json)
    @srv = TestUtil.fork_process("clustering", PORT, "config_clustering.json")
    @cli = Jubatus::Clustering::Client::Clustering.new(HOST, PORT, "name")
  end

  def teardown
    TestUtil.kill_process(@srv)
  end

  def test_get_client
    assert_instance_of( MessagePack::RPC::Client, @cli.get_client )
  end

  def test_get_config
    config = @cli.get_config
    assert_equal(JSON.parse(config), @config)
  end

  def test_save
    assert_equal(@cli.save("clustering.save_test.model").size, 1)
  end

  def test_load
    model_name = "clustering.load_test.model"
    @cli.save(model_name)
    assert_equal(true, @cli.load(model_name))
  end

  def test_get_status
    @cli.get_status
  end

  def test_push
    d = Jubatus::Clustering::IndexedPoint.new("test", Jubatus::Common::Datum.new)
    res = @cli.push([d])
  end

  def test_get_revision
    r = @cli.get_revision
    assert_instance_of(Fixnum, r)
  end

  def test_get_core_members
    for i in 0..99
      d = Jubatus::Common::Datum.new({"nkey1" => i, "nkey2" => -i})
      @cli.push([Jubatus::Clustering::IndexedPoint.new(i.to_s, d)])
    end
    res = @cli.get_core_members()
    assert_equal(10, res.length)
    assert_instance_of(Jubatus::Clustering::WeightedDatum, res[0][0])
  end

  def test_get_core_members_light
    for i in 0..99
      d = Jubatus::Common::Datum.new({"nkey1" => i, "nkey2" => -i})
      @cli.push([Jubatus::Clustering::IndexedPoint.new(i.to_s, d)])
    end
    res = @cli.get_core_members_light()
    assert_equal(10, res.length)
    assert_instance_of(Jubatus::Clustering::WeightedIndex, res[0][0])
  end

  def test_k_center
    for i in 0..99
      d = Jubatus::Common::Datum.new({"nkey1" => i, "nkey2" => -i})
      @cli.push([Jubatus::Clustering::IndexedPoint.new(i.to_s, d)])
    end
    res = @cli.get_k_center()
    assert_equal(10, res.length)
    assert_instance_of(Jubatus::Common::Datum, res[0])
  end

  def test_nearest_center
    for i in 0..99
      d = Jubatus::Common::Datum.new({"nkey1" => i, "nkey2" => -i})
      @cli.push([Jubatus::Clustering::IndexedPoint.new(i.to_s, d)])
    end
    q = Jubatus::Common::Datum.new({"nkey1" => 2.0, "nkey2" => 1.0})
    res = @cli.get_nearest_center(q)
    assert_instance_of(Jubatus::Common::Datum, res)
  end

  def test_nearest_members
    for i in 0..99
      d = Jubatus::Common::Datum.new({"nkey1" => i, "nkey2" => -i})
      @cli.push([Jubatus::Clustering::IndexedPoint.new(i.to_s, d)])
    end
    q = Jubatus::Common::Datum.new({"nkey1" => 2.0, "nkey2" => 1.0})
    res = @cli.get_nearest_members(q)
    assert_instance_of(Jubatus::Clustering::WeightedDatum, res[0])
  end

end
