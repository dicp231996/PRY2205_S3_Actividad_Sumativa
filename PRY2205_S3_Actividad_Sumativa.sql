/* ==========================================================
   PRY2205 - Consulta de Bases de Datos
   Semana 3 - Actividad sumativa: Aplicando funciones de agrupación
   Conexión: PRY2205_ACTIVIDAD_S3 (usuario PRY2205_S3)
   ========================================================== */

/* ----------------------------------------------------------
   CASO 1: Análisis de Propiedades
   Variable de sustitución: VALOR_TOTAL_GASTO_COMUN (ej: 100000)
   ---------------------------------------------------------- */
SELECT UPPER(id_tipo_propiedad) "TIPO",
       COUNT(*) "TOTAL_PROPIEDADES",
       TO_CHAR(MAX(valor_arriendo), '$9G999G999') "MAX_ARRIENDO",
       TO_CHAR(ROUND(AVG(valor_arriendo)), '$9G999G999') "PROMEDIO_ARRIENDO",
       TO_CHAR(MIN(valor_arriendo), '$9G999G999') "MIN_ARRIENDO",
       CASE
           WHEN MAX(valor_arriendo) <= 1000000 THEN 'ESTÁNDAR'
           ELSE 'PREMIUM'
       END "CLASIFICACION",
       TO_CHAR(SUM(NVL(valor_gasto_comun, 0)), '$9G999G999') "TOTAL_GASTOS_COMUNES"
  FROM propiedad
 GROUP BY id_tipo_propiedad
HAVING SUM(NVL(valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
 ORDER BY SUM(NVL(valor_gasto_comun, 0)) DESC;


/* ----------------------------------------------------------
   CASO 2: Análisis de antigüedad de empleados
   Variable de sustitución: CODIGO_SUCURSAL (ej: 30 = Providencia)
   ---------------------------------------------------------- */
SELECT UPPER(nombre_emp || ' ' || appaterno_emp) "Nombre Empleado",
       TO_CHAR(sueldo_emp, '$9G999G999') "Sueldo con Formato",
       CASE
           WHEN sueldo_emp > 2000000 THEN 'ALTO'
           ELSE 'MEDIO'
       END "Clasificación Sueldo",
       TO_CHAR(TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12)) "Años Antigüedad",
       CASE
           WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 5 AND 10
                THEN 'Corresponde bono  5%:' || TO_CHAR(ROUND(sueldo_emp * 0.05), '$9G999G999')
           WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 11 AND 20
                THEN 'Corresponde bono 10%:' || TO_CHAR(ROUND(sueldo_emp * 0.10), '$9G999G999')
           ELSE 'Corresponde bono 15%:' || TO_CHAR(ROUND(sueldo_emp * 0.15), '$9G999G999')
       END "BONO"
  FROM empleado
 WHERE id_categoria_emp = 3
   AND id_sucursal <> &CODIGO_SUCURSAL
   AND TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) > 5
 ORDER BY sueldo_emp DESC;


/* ----------------------------------------------------------
   CASO 3: Lista de clientes
   COUNT(celular_cli) no cuenta los nulos: si da 0, ningún
   cliente de la clasificación tiene teléfono.
   ---------------------------------------------------------- */
SELECT CASE
           WHEN renta_cli >= 1000000 THEN 'PREMIUM'
           WHEN renta_cli BETWEEN 600000 AND 999999 THEN 'ALTA'
           WHEN renta_cli BETWEEN 300000 AND 599999 THEN 'MEDIA'
           ELSE 'BAJA'
       END "CLASIFICACION_RENTA",
       COUNT(*) "CANTIDAD_CLIENTES",
       TO_CHAR(ROUND(AVG(renta_cli)), '$9G999G999') "RENTA_PROMEDIO",
       CASE
           WHEN COUNT(celular_cli) = 0 THEN 'Clientes Sin Teléfono'
           ELSE 'Clientes con Teléfono'
       END "ESTADO_TELEFONO"
  FROM cliente
 GROUP BY CASE
              WHEN renta_cli >= 1000000 THEN 'PREMIUM'
              WHEN renta_cli BETWEEN 600000 AND 999999 THEN 'ALTA'
              WHEN renta_cli BETWEEN 300000 AND 599999 THEN 'MEDIA'
              ELSE 'BAJA'
          END
HAVING AVG(renta_cli) > 200000;
