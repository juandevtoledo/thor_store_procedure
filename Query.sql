--
----- Certificados x Terceros ------------------------------------
select cer_Id,tr.ter_id,tr.ter_Nombres,p.paga_Nombre as pagaduria,
con.con_Nombre as Convenio, con.con_Id as ConveniorId,  pr.pro_Nombre , pr.pro_Id as Producto
from
NewCertificado nc
inner join Pagaduria p on (p.paga_id = nc.paga_Id)
inner join NewConvenio con on (nc.cer_Convenio = con.con_Id)
inner join NewProducto pr on (pr.pro_Id = nc.pro_Id)
inner join NewTercero tr on (tr.ter_Id= nc.ter_Id)
where nc.ter_Id=27517984;

--
----- Debug :: Table ------------------------------------
 create table debug(
  id_tercer NUMERIC(18,0),
  cer_id NUMERIC(18,0),
  apl_pago_vigencia date,
  apl_pago_valor NUMERIC(18,0),
  cer_vigencia date,
  cer_prima_total NUMERIC(18,0),
  cer_vigencia_retiro_principal date,
  prima_total NUMERIC(18,0),
  condition INT
 );
--
----- Exec :: Procedure vigencias------------------------------------
declare @vigencia date
declare @valorAplicar NUMERIC(18,0)
EXEC dbo.sp_obtener_vigencia 7517984 ,74248, @vigencia OUTPUT, @valorAplicar OUTPUT
SELECT @vigencia,@valorAplicar
--
----- Exec :: Certificacion por tercero------------------------------------
EXEC dbo.sp_certificacion_por_tercero 27517984 ,140;
select * from debug;
