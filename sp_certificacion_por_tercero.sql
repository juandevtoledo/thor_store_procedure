-- =============================================
-- Author:		Juan Gabriel Toledo
-- Create date: 2020-08-19
-- Description:	Procedimiento almacenado para consultar los certificados a los cuales se les va a
--				realizar la aplicación de un pago		
-- =============================================
ALTER PROCEDURE [sp_certificacion_por_tercero] 
    @ter_Id NUMERIC(18,0),
	@cer_Convenio int  
AS   
DECLARE @cer_id_result NUMERIC(18,0)
DECLARE @ter_id_result NUMERIC(18,0)
DECLARE @pro_id_result NUMERIC(18,0)
DECLARE @vigencia_aplicar date
DECLARE @valor_aplicar NUMERIC(18,0)
DECLARE @cer_id_vigente NUMERIC(18,0)
DECLARE @estado_certificado varchar(255)
DECLARE @getid CURSOR
SET NOCOUNT ON;  
 -- Tabla para guardar certificados del tercero
 create table #certificados_por_tercero
 (
		cer_id NUMERIC(18,0),
        ter_Id NUMERIC(18,0),
		prod_id NUMERIC(18,0),
        valor_aplicar NUMERIC(18,0),
		vigencia_aplicar date
 )
--Buscar Certificados vigentes 
--Businnes Rules
--1)Que esten en estado Modificado , Vigente ,  CANCELACION CON CARTA DE RETIRO ( sea 3 mese atras) 

SET @getid = CURSOR FOR
select cer_Id,tr.ter_id,nc.pro_Id,nc.cer_EstadoNegocio
from
NewCertificado nc
inner join Pagaduria p on (p.paga_id = nc.paga_Id)
inner join NewConvenio con on (nc.cer_Convenio = con.con_Id)
inner join NewProducto pr on (pr.pro_Id = nc.pro_Id)
inner join NewTercero tr on (tr.ter_Id= nc.ter_Id)
where nc.ter_Id=@ter_Id
and con.con_Id = @cer_Convenio
and (nc.cer_EstadoNegocio IN ('MODIFICADO','VIGENTE')
or  (nc.cer_EstadoNegocio = 'CANCELACION CON CARTA DE RETIRO' and nc.VigenciaRetiroPrincipal between dateadd(month,-3,DATEADD(mm,DATEDIFF(mm,0,getdate()),0)) and  DATEADD(mm,DATEDIFF(mm,0,getdate()),0)))
and not(nc.cer_EstadoNegocio = 'VIGENTE' and 1  = (select count(*) from NewCertificado ncmdf where  ncmdf.ter_Id=@ter_Id and ncmdf.cer_Convenio = @cer_Convenio and ncmdf.cer_EstadoNegocio = 'MODIFICADO'))


OPEN @getid
FETCH NEXT
FROM @getid INTO @cer_id_result, @ter_id_result,@pro_id_result,@estado_certificado
WHILE @@FETCH_STATUS = 0
BEGIN

	 if (@estado_certificado='MODIFICADO')
		SELECT @cer_id_vigente = (select top 1 nc.cer_Id from NewCertificado nc where nc.ter_Id=@ter_Id and nc.cer_Convenio = @cer_Convenio and nc.cer_EstadoNegocio =  'VIGENTE')
	 else
		SELECT @cer_id_vigente = 0

	 EXEC dbo.sp_obtener_vigencia @ter_Id ,@cer_id_result,@cer_id_vigente, @vigencia_aplicar OUTPUT , @valor_aplicar OUTPUT	
	
	 insert into #certificados_por_tercero (cer_id, ter_Id,prod_id,valor_aplicar,vigencia_aplicar)
	 values (@cer_id_result,@ter_id_result, @pro_id_result,@valor_aplicar,@vigencia_aplicar)	 

	 FETCH NEXT
	 FROM @getid INTO @cer_id_result, @ter_id_result,@pro_id_result,@estado_certificado
END
CLOSE @getid
DEALLOCATE @getid

SELECT * FROM #certificados_por_tercero where valor_aplicar <> 0;
GO 