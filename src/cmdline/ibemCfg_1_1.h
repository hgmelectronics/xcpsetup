#include <stdint.h>

typedef struct VocModelParam {
	float soc[11], voc[11];
} VocModelParam;

typedef struct RiModelParam {
	float socBreakpt, rAtZeroSOC, dRdSOCLow, dRdSOCHigh;
	float rInterconn, rDToRC;
} RiModelParam;

typedef struct ModelParam {
	float minR, maxR;
	float srVarI, srVarSOC, srVarRPerI, srVarRMinI, srVarMeasV, srMinBetaV;
	float nomCellCap, nomCellR;
	float usableDischI, usableChgI;
	float capEstHistLength;
} ModelParam;

typedef struct BalParam {
	float qPerVSec, minAccQ, maxAccQ, stopQ;
} BalParam;

typedef struct ProtParam {
	float highTMaxV, lowTMaxV;
	float highTForMaxV, lowTForMaxV;

	float highTMinV, lowTMinV;
	float highTForMinV, lowTForMinV;

	float rForCellProt;
	float thermalMaxI, zeroITemp;

	float safeMaxT, highWarnT;
	float safeMinT, lowWarnT;
} ProtParam;

typedef struct CellTypeParam {
	VocModelParam vocParam;
	RiModelParam riParam;
	ModelParam modelParam;
	BalParam balParam;
	ProtParam protParam;
} CellTypeParam;

typedef struct SeriesRDivVSensorCalib {
	int16_t zeroCts[8];
	float scale[8];
} SeriesRDivVSensorCalib;

typedef struct IBEMConfig {
	unsigned char boardID;																//!< ID used for CAN messaging. This board covers cells from boardID * 8 to boardID * 8 + 7.
	SeriesRDivVSensorCalib afeCalib;	//!< Calibration for the analog front end that measures cell voltages
	CellTypeParam cellTypeParam;										//!< Cell type information structure
} IBEMConfig;
