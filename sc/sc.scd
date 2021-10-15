(
Server.supernova;
o = s.options;
o.sampleRate_(48000);
o.blockSize_(128);
o.memSize_(16384);
o.numInputBusChannels_(0);
o.outDevice_("bcm2835 Headphones");
o.numOutputBusChannels_(2);
s.waitForBoot({

	~decoder = FoaDecoderKernel.newCIPIC(15, s, s.sampleRate.asInteger);

	~moscaInstance = Mosca(
        	// projDir: "/home/oscar/auto",
        	// rirBank: "/home/oscar/rirBank",
        	nsources: 49, // Set the number of sources
        	decoder: ~decoder);

	s.sync;
	PathName("/home/oscar/demo").entries.do({ | item, count | ~moscaInstance.inputFile(count + 1, item.fullPath, true) });
        s.sync;

	//~moscaInstance.syncFiles(true);
	//~moscaInstance.ossiaParent.exposeOSCQueryServer();
	~moscaInstance.ossiaParent.exposeOSC("192.168.1.2");

	// Pozyx setup
	Pipe("python3 ~/pozyx.py", "w");
	~moscaInstance.headTracker(8888, type:\pozyxOSC, extraArgs: [8500, 5700, 2690]);	
});
)

/*	 0003
	 0008
	 0009
	 0010
	 0011
	 0012
	 0015
	 0017
	 0018
	 0019
	 0020
	 0021
	 0027
	 0028
	 0033
	 0040
	 0044
	 0048
	 0050
	 0051
	 0058
	 0059	
	 0061
	 0065
	 0119
	 0124
	 0126
	 0127
	 0131
	 0133
	 0134
	 0135
	 0137
	 0147
	 0148
	 0152
	 0153
	 0154
	 0155
	 0156
	 0158
	 0162
	 0163
	 0165*/
