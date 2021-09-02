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
	
	~decoder = FoaDecoderKernel.newCIPIC(21, s, s.sampleRate.asInteger);

	~moscaInstance = Mosca(
        	// projDir: "/home/oscar/auto",
        	// rirBank: "/home/oscar/rirBank",
        	nsources: 15, // Set the number of sources
        	decoder: ~decoder)
	//.gui()
	;

	s.sync;

	PathName("/home/oscar/demo").entries.do({ | item, count | ~moscaInstance.inputFile(count + 1, item.fullPath, true) });

	//~moscaInstance.syncFiles(true);

	~moscaInstance.ossiaParent.exposeOSCQueryServer();

	// Pozyx setup
	Pipe("python3 ~/pozyx.py", "w");
	~moscaInstance.headTracker(8888, type:\pozyxOSC, extraArgs: [8500, 5700, 2690]);	
});
)
