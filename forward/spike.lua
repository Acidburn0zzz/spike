local B = require("apps.basic.basic_apps")
local P = require("apps.pcap.pcap")
local Rewriting = require("rewriting")

if #main.parameters ~= 5 then
   print("Usage: spike src_mac dst_mac ipv4_addr in.pcap out.pcap")
   os.exit(1)
end

src_mac, dst_mac, ipv4_addr, incap, outcap = unpack(main.parameters)

local c = config.new()
config.app(c, "source", P.PcapReader, incap)
-- only 1 rewriting app for now, since there's not much benefit to
-- having more without multithreading
-- TODO investigate snabb multithreading
config.app(c, "rewriting", Rewriting, {src_mac = src_mac,
                                       dst_mac = dst_mac,
                                       ipv4_addr = ipv4_addr})
config.app(c, "sink", P.PcapWriter, outcap)
config.link(c, "source.output -> rewriting.input")
config.link(c, "rewriting.output -> sink.input")

engine.configure(c)
engine.main({duration = 1, report = {showlinks = true}})