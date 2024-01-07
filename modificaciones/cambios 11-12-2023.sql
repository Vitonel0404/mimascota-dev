DROP FUNCTION public.fn_buscar_producto_sucursal(
	producto character varying,
	sucursal integer);

CREATE OR REPLACE FUNCTION public.fn_buscar_producto_sucursal(
	producto character varying,
	sucursal integer)
    RETURNS TABLE(id_prod_suc integer, precio numeric, stock integer, stockmin integer, estado boolean, id_prod integer, id_sucursal integer, prod_id integer, nombre character varying, descripcion text, estad boolean, id_categ integer, id_empresa int, id_unid_med integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
declare
begin
return query
select * from productos_productosucursal as ps 
inner join productos_producto as p on ps.id_producto_id=p.id_producto 
where ps.estado=true and p.nombre ilike '%'||producto||'%' and ps.id_sucursal_id=sucursal;
end;
$BODY$;