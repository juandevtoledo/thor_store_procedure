USE [thor_pruebas]
GO  
-- =============================================
-- Author:		Juan Gabriel Toledo
-- Create date: 2020-08-19
-- Description:	Procedimiento almacenado para consultar los certificados a los cuales se les va a
--				realizar la aplicación de un pago		
-- =============================================
ALTER PROCEDURE [sp_obtener_vigencia] 
    @ter_Id  NUMERIC(18,0),
	@cer_id  NUMERIC(18,0),
	@vigencia date OUTPUT
AS
DECLARE @apl_pago_vigencia date
DECLARE @apl_pago_valor NUMERIC(18,0)
BEGIN
	   -- Se busca la maxima fecha de la aplicacin pago
	 -- TO DO: pasar esto a una funcion o store procedure
	 select top 1  @apl_pago_vigencia=apl.aplPago_Vigencia,@apl_pago_valor=aplPago_Valor
	 FROM dbo.NewAplicacionPagos apl
	 where apl.dev_Id = 0 and apl.aplPago_Reversion <> 2 
	 and apl.ter_Id=@ter_Id and apl.cer_Id = @cer_id
	 order by aplPago_Vigencia desc
	 --Se calcula vigencia
	 /*
	 when apl.aplpago_vigencia >= cer.cer_VigenciaDesde and cer.cer_PrimaTotal = apl.aplPago_Valor and DATEADD(month,-1,isnull(cer.VigenciaRetiroPrincipal,'01/01/3000'))>apl.aplPago_Vigencia 
then DATEADD(month,1,apl.aplpago_vigencia)
--Caso 2
when apl.aplpago_vigencia >= cer.cer_VigenciaDesde and cer.cer_PrimaTotal > apl.aplPago_Valor then DATEADD(month,0,apl.aplpago_vigencia)
when isnull(apl.aplPago_Vigencia,apl2.aplPago_Vigencia)  = dateadd(month,-1,cer.cer_VigenciaDesde) and cer2.cer_PrimaTotal = apl2.aplPago_Valor
	then DATEADD(month,1,apl2.aplpago_vigencia)
--Caso 3	
when isnull(apl.aplPago_Vigencia,apl2.aplPago_Vigencia) < cer.cer_VigenciaDesde and cer2.cer_PrimaTotal > apl2.aplPago_Valor
	then DATEADD(month,0,apl2.aplpago_vigencia)
when isnull(apl.aplPago_Vigencia,apl2.aplPago_Vigencia) < dateadd(month,-1,cer.cer_VigenciaDesde) and cer2.cer_PrimaTotal = apl2.aplPago_Valor
	then DATEADD(month,1,apl2.aplpago_vigencia)
--Caso 3		
when isnull(isnull(apl.aplPago_Vigencia,apl2.aplPago_Vigencia),cer.cer_VigenciaDesde) = cer.cer_VigenciaDesde 
	and (cer.VigenciaRetiroPrincipal is null or cer.VigenciaRetiroPrincipal>cer.cer_VigenciaDesde)
	then cer.cer_VigenciaDesde
--Caso 4	
when isnull(apl.aplPago_Vigencia,apl2.aplPago_Vigencia) >= cer.cer_VigenciaDesde and DATEADD(month,-1,isnull(cer.VigenciaRetiroPrincipal,'01/01/3000'))> isnull(apl.aplPago_Vigencia,apl2.aplPago_Vigencia)
	then '01/01/3000'
--Default
ELSE DATEADD(mm,DATEDIFF(mm,0,getdate()),0)
 end 'VIGENCIA APLICAR'
	 */
	  SELECT @vigencia = getdate()
END;