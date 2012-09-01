#include <chuck_dl.h>
#include <chuck_def.h>

CK_DLL_TICKF(gainmod_tick);

CK_DLL_QUERY(GainMod)
{
	QUERY->setname(QUERY, "GainMod");

	QUERY->begin_class(QUERY, "GainMod", "UGen_Stereo");
	QUERY->add_ugen_funcf(QUERY, gainmod_tick, NULL, 2, 1);
	QUERY->end_class(QUERY);

	return TRUE;
}

CK_DLL_TICKF(gainmod_tick)
{
	*out = in[0] * in[1];

	return TRUE;
}
