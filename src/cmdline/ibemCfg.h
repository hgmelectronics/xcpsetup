#include <stdint.h>

typedef struct VocModelParam {
	float soc[11], voc[11];
} VocModelParam;

typedef struct SplineRiModelParam {
	float chgSOC[11], chgR[11];
	float dischSOC[11], dischR[11];
	float tempcoTemp[11], tempcoRatio[11];
} SplineRiModelParam;

typedef struct ModelParam {
	float minR, maxR;
	float fclSOCGain, fclRGain;
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
	SplineRiModelParam riParam;
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
