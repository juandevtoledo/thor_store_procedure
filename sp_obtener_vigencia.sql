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
	@vigencia date OUTPUT,
	@valorAplicar NUMERIC(18,0) OUTPUT
AS
DECLARE @apl_pago_vigencia date
DECLARE @apl_pago_valor NUMERIC(18,0)
DECLARE @cer_vigencia date
DECLARE @cer_prima_total NUMERIC(18,0)
DECLARE @cer_vigencia_retiro_principal date
DECLARE @prima_total NUMERIC(18,0)

BEGIN
	 -- Se busca la maxima fecha de la aplicacin pago
	 select top 1  @apl_pago_vigencia=apl.aplPago_Vigencia,@apl_pago_valor=aplPago_Valor
	 FROM dbo.NewAplicacionPagos apl
	 where apl.dev_Id = 0 and apl.aplPago_Reversion <> 2 
	 and apl.ter_Id=@ter_Id and apl.cer_Id = @cer_id
	 order by aplPago_Vigencia desc
	 -- se busca informacion del certificado 
	 select @cer_vigencia=cer.cer_VigenciaDesde , @cer_prima_total=cer.cer_PrimaTotal,
	 @cer_vigencia_retiro_principal=VigenciaRetiroPrincipal,
	 @prima_total=cer_PrimaTotal
	 from NewCertificado cer
	 where cer.cer_id=@cer_id
	 --Se identifica la vigencia, segun Businnes Rule 
	 --Businnes Rule 1 :
	 IF @apl_pago_vigencia>=@cer_vigencia and @cer_prima_total = @apl_pago_valor and DATEADD(month,-1,isnull(@cer_vigencia_retiro_principal,'01/01/3000'))>@apl_pago_vigencia 
	 BEGIN
		SELECT @vigencia = DATEADD(month,1,@apl_pago_vigencia )
		SELECT @valorAplicar = @prima_total
		-- Debug (Borrar)
		insert into debug values(@ter_Id ,@cer_id,@apl_pago_vigencia,@apl_pago_valor,@cer_vigencia,@cer_prima_total, @cer_vigencia_retiro_principal,@prima_total,1);
	 END
	 --Businnes Rule 2 :
	 ELSE IF @apl_pago_vigencia>=@cer_vigencia	and @cer_prima_total >= @apl_pago_valor
	 BEGIN
		SELECT @vigencia = DATEADD(month,0,@apl_pago_vigencia)
		SELECT @valorAplicar = @prima_total - @apl_pago_valor
		-- Debug (Borrar)
		insert into debug values(@ter_Id ,@cer_id,@apl_pago_vigencia,@apl_pago_valor,@cer_vigencia,@cer_prima_total, @cer_vigencia_retiro_principal,@prima_total,2);
	 END
	 --Businnes Rule 3 :
	 ELSE IF isnull(@apl_pago_vigencia,@cer_vigencia)= @cer_vigencia and (@cer_vigencia is null or @cer_vigencia_retiro_principal>@cer_vigencia)
	 BEGIN 
		SELECT @vigencia =@cer_vigencia
		SELECT @valorAplicar = @prima_total
		-- Debug (Borrar)
		insert into debug values(@ter_Id ,@cer_id,@apl_pago_vigencia,@apl_pago_valor,@cer_vigencia,@cer_prima_total, @cer_vigencia_retiro_principal,@prima_total,3);
     END
	 --Businnes Rule 4 :
     ELSE IF @apl_pago_vigencia>= @cer_vigencia and DATEADD(month,-1,isnull(@cer_vigencia_retiro_principal,'01/01/3000'))> @apl_pago_vigencia
	 BEGIN
		SELECT @vigencia =@cer_vigencia
		SELECT @valorAplicar = @prima_total
		-- Debug (Borrar)
		insert into debug values(@ter_Id ,@cer_id,@apl_pago_vigencia,@apl_pago_valor,@cer_vigencia,@cer_prima_total, @cer_vigencia_retiro_principal,@prima_total,4);
	 END
	 --Businnes Rule Default :
	 ELSE
	 BEGIN
		SELECT @vigencia =DATEADD(mm,DATEDIFF(mm,0,getdate()),0)
		SELECT @valorAplicar = 0
		-- Debug (Borrar)
		insert into debug values(@ter_Id ,@cer_id,@apl_pago_vigencia,@apl_pago_valor,@cer_vigencia,@cer_prima_total, @cer_vigencia_retiro_principal,@prima_total,-1);
	 END
	 
END;