TITLE 'Análisis Estadístico: Modelo Alométrico Especie';

/*
* Leer archivo .txt delimitado por tabulaciones 
PROC IMPORT DATAFILE="/folders/myfolders/Modelos_Alométricos/Especie/Datos_Especie.txt" OUT=WORK.DATOS_INI 
DBMS=TAB REPLACE;
GETNAMES=YES;
RUN;
*/

/*
/* Leer hoja de excel 
PROC IMPORT DATAFILE="/folders/myfolders/Modelos_Alométricos/Especie/Datos_Especie.xlsx" OUT=WORK.DATOS_INI 
DBMS=XLSX REPLACE;
SHEET="Datos_Especie";
GETNAMES=YES;
RUN;
*/


/* Transformación de variables */
DATA WORK.DATOS_T;
	SET WORK.DATOS_INI;
	LN_HT_m = log(HT_m);
	LN_DAP_cm = log(DAP_cm);
	LN_Edad_m = log(Edad_m);
	LN_DAP2 = log(DAP_cm*DAP_cm);
	LN_DAP2_Edad = log(DAP_cm*DAP_cm*Edad_m);
RUN;



/* Incluir LN_HT_media en base de datos */
PROC SQL;
CREATE TABLE WORK.DATOS AS
SELECT *,
mean(LN_HT_m) AS LN_HT_media FORMAT = 12.10
FROM WORK.DATOS_T;
QUIT; 



/* Atributos de la base de datos */
PROC DATASETS ;
	CONTENTS DATA=WORK.DATOS ORDER=collate;
QUIT;



/* Generar informe */
ODS RTF FILE="/folders/myfolders/Modelos_Alométricos/Especie/Modelo_Especie.rtf";

ODS GRAPHICS ON;










/* 1) Modelo de Potencia Linealizado */

/* Estructura Autorregresiva de Primer Orden Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP_cm/ SOLUTION  OUTPRED=PRED_1_ARH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=ARH(1);
ODS OUTPUT InfoCrit=CRIT_1_ARH;
RUN;

/* Calcular medidas de desempeño predictivo */
%INCLUDE '/folders/myfolders/ERROR.sas';
%mae_rmse_ef(PRED_1_ARH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_1_ARH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_1_ARH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '1_ARH';
	END;
RUN;





/* Estructura Compuesta Simétrica Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP_cm/ SOLUTION OUTPRED=PRED_1_CSH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=CSH;
ODS OUTPUT InfoCrit=CRIT_1_CSH;
RUN;

/* Calcular medidas de desempeño predictivo */
%mae_rmse_ef(PRED_1_CSH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_1_CSH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_1_CSH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '1_CSH';
	END;
RUN;





/* Estructura Toeplitz Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP_cm/ SOLUTION  OUTPRED=PRED_1_TOEPH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=TOEPH;
ODS OUTPUT InfoCrit=CRIT_1_TOEPH;
RUN;

/* Calcular medidas de desempeño predictivo */
%mae_rmse_ef(PRED_1_TOEPH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_1_TOEPH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_1_TOEPH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '1_TOEPH';
	END;
RUN;










/* 2) Modelo de Potencia Linealizado de Doble Entrada */

/* Estructura Autorregresiva de Primer Orden Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP2_Edad/ SOLUTION OUTPRED=PRED_2_ARH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=ARH(1);
ODS OUTPUT InfoCrit=CRIT_2_ARH;
RUN;

/* Calcular medidas de desempeño predictivo */
%mae_rmse_ef(PRED_2_ARH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_2_ARH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_2_ARH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '2_ARH';
	END;
RUN;





/* Estructura Compuesta Simétrica Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP2_Edad/ SOLUTION OUTPRED=PRED_2_CSH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=CSH;
ODS OUTPUT InfoCrit=CRIT_2_CSH;
RUN;

/* Calcular medidas de desempeño predictivo */
%mae_rmse_ef(PRED_2_CSH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_2_CSH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_2_CSH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '2_CSH';
	END;
RUN;





/* Estructura Toeplitz Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP2_Edad/ SOLUTION OUTPRED=PRED_2_TOEPH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=TOEPH;
ODS OUTPUT InfoCrit=CRIT_2_TOEPH;
RUN;

/* Calcular medidas de desempeño predictivo */
%mae_rmse_ef(PRED_2_TOEPH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_2_TOEPH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_2_TOEPH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '2_TOEPH';
	END;
RUN;










/* 3) Modelo de Polinomial */

/* Estructura Autorregresiva de Primer Orden Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP_cm LN_DAP2/ SOLUTION OUTPRED=PRED_3_ARH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=ARH(1);
ODS OUTPUT InfoCrit=CRIT_3_ARH;
RUN;

/* Calcular medidas de desempeño predictivo */
%mae_rmse_ef(PRED_3_ARH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_3_ARH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_3_ARH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '3_ARH';
	END;
RUN;





/* Estructura Compuesta Simétrica Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP_cm LN_DAP2/ SOLUTION OUTPRED=PRED_3_CSH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=CSH;
ODS OUTPUT InfoCrit=CRIT_3_CSH;
RUN;

/* Calcular medidas de desempeño predictivo */
%INCLUDE '/folders/myfolders/ERROR.sas';
%mae_rmse_ef(PRED_3_CSH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_3_CSH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_3_CSH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '3_CSH';
	END;
RUN;





/* Estructura Toeplitz Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP_cm LN_DAP2/ SOLUTION OUTPRED=PRED_3_TOEPH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=TOEPH;
ODS OUTPUT InfoCrit=CRIT_3_TOEPH;
RUN;

/* Calcular medidas de desempeño predictivo */
%mae_rmse_ef(PRED_3_TOEPH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_3_TOEPH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_3_TOEPH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '3_TOEPH';
	END;
RUN;










/* 4) Modelo de Múltiple */

/* Estructura Autorregresiva de Primer Orden Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP_cm LN_Edad_m/ SOLUTION OUTPRED=PRED_4_ARH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=ARH(1);
ODS OUTPUT InfoCrit=CRIT_4_ARH;
RUN;

/* Calcular medidas de desempeño predictivo */
%mae_rmse_ef(PRED_4_ARH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_4_ARH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_4_ARH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '4_ARH';
	END;
RUN;




/* Estructura Compuesta Simétrica Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP_cm LN_Edad_m/ SOLUTION OUTPRED=PRED_4_CSH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=CSH;
ODS OUTPUT InfoCrit=CRIT_4_CSH;
RUN;

/* Calcular medidas de desempeño predictivo */%mae_rmse_ef(PRED_4_CSH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_4_CSH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_4_CSH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '4_CSH';
	END;
RUN;





/* Estructura Toeplitz Heterogénea */
PROC MIXED DATA = WORK.DATOS PLOTS=STUDENTPANEL METHOD=REML IC;
	CLASS ID_Arbol Muestreo;
	MODEL LN_HT_m = LN_DAP_cm LN_Edad_m/ SOLUTION OUTPRED=PRED_4_TOEPH;
REPEATED Muestreo / SUBJECT=ID_Arbol TYPE=TOEPH;
ODS OUTPUT InfoCrit=CRIT_4_TOEPH;
RUN;

/* Calcular medidas de desempeño predictivo */
%mae_rmse_ef(PRED_4_TOEPH,LN_HT_m,Pred,LN_HT_media);
RUN;

/* Añadirlas a las medidas de bondad de ajuste */
DATA WORK.CRIT_4_TOEPH (KEEP = MODELO AIC BIC MAE RCME EFICIENCIA);
	FORMAT MODELO AIC BIC MAE RCME EFICIENCIA;
	SET WORK.CRIT_4_TOEPH;
	MAE = &mae;   /* Error Medio Absoluto */
	RCME = &rmse;  /* Raíz Cuadrada del Error Cuadrático Medio */
	EFICIENCIA = &ef;  /* Eficiencia */
	IF _n_ = 1 THEN DO;
	MODELO = '4_TOEPH';
	END;
RUN;










PROC SQL;
CREATE TABLE WORK.CRIT AS
SELECT * FROM CRIT_1_ARH
UNION
SELECT * FROM CRIT_1_CSH
UNION
SELECT * FROM CRIT_1_TOEPH
UNION
SELECT * FROM CRIT_2_ARH
UNION
SELECT * FROM CRIT_2_CSH
UNION
SELECT * FROM CRIT_2_TOEPH
UNION
SELECT * FROM CRIT_3_ARH
UNION
SELECT * FROM CRIT_3_CSH
UNION
SELECT * FROM CRIT_3_TOEPH
UNION
SELECT * FROM CRIT_4_ARH
UNION
SELECT * FROM CRIT_4_CSH
UNION
SELECT * FROM CRIT_4_TOEPH;
QUIT; 





/* Mostrar resultados */
PROC PRINT DATA=WORK.CRIT;
   TITLE 'Tabla de Criterios';
RUN;





ODS GRAPHICS OFF;

ODS RTF CLOSE;