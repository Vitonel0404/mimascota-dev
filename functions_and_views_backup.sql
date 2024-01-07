
-- Name: fn_buscar_detalle_compra(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_buscar_detalle_compra(id_compra integer) RETURNS TABLE(nombre_p character varying, precio_p numeric, cantidad_p smallint, subtotal_p numeric)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select pp.nombre, cd.precio, cd.cantidad,cd.subtotal
	from compras_detallecompra as cd
	inner join productos_producto as pp on pp.id_producto=cd.id_producto_id
	where id_compra_id=id_compra;
end;
$$;


--
-- Name: fn_buscar_detalle_venta(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_buscar_detalle_venta(id_venta integer) RETURNS TABLE(venta_id integer, nombre_p character varying, precio_p numeric, cantidad_p smallint, subtotal_p numeric)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select vd.id_venta_id,pp.nombre, vd.precio, vd.cantidad,vd.subtotal
	from ventas_detalleventa as vd
	inner join productos_producto as pp on pp.id_producto=vd.id_producto_id
	where id_venta_id=id_venta;
end;
$$;


--
-- Name: fn_buscar_producto_sucursal(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_buscar_producto_sucursal(producto character varying, sucursal integer) RETURNS TABLE(id_prod_suc integer, precio numeric, stock integer, stockmin integer, estado boolean, id_prod integer, id_sucursal integer, prod_id integer, nombre character varying, descripcion text, estad boolean, id_categ integer, id_empresa int, id_unid_med integer)
    LANGUAGE plpgsql
    AS $$
declare
begin
return query
select * from productos_productosucursal as ps 
inner join productos_producto as p on ps.id_producto_id=p.id_producto 
where ps.estado=true and p.nombre ilike '%'||producto||'%' and ps.id_sucursal_id=sucursal;
end;
$$;


--
-- Name: fn_buscar_recordatorio_mascota(integer, date, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_buscar_recordatorio_mascota(historia integer, fech date, id_empresa integer) RETURNS TABLE(descripcion character varying, fecha date, comentario text, id_recordatorio integer)
    LANGUAGE plpgsql
    AS $$
declare
begin
	return query
    select gs.descripcion, gr.fecha,gr.comentario,gr.id_recordatorio 
    from gestion_recordatorio as gr 
    inner join gestion_servicio as gs on gr.id_servicio_id=gs.id_servicio
	inner join gestion_mascota as gm on gm.id_mascota = gr.id_mascota_id
    where gm.numero_historia=historia and gm.id_empresa_id=id_empresa and gr.fecha=fech and gr.estado=true;
end;
$$;


--
-- Name: fn_consultar_detalle_atencion(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_consultar_detalle_atencion(atencion integer) RETURNS TABLE(nombre character varying, monto numeric)
    LANGUAGE plpgsql
    AS $$
declare
begin
	return query
	select se.descripcion, dt.monto from gestion_detalle_atencion as dt 
    inner join gestion_servicio as se on dt.id_servicio_id=se.id_servicio 
    where dt.id_atencion_id=atencion;
end;
$$;


--
-- Name: fn_correos_recordatorios_pendientes(date, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_correos_recordatorios_pendientes(fech date, usu character varying) RETURNS TABLE(correo character varying, cliente character varying, mascota character varying)
    LANGUAGE plpgsql
    AS $$
declare
id_sucu integer;
begin
	select us.id_sucursal into id_sucu  from usuarios_usuario as us where us.username=usu;
	return query
	select gp.correo, gp.nombre,gm.nombre from gestion_recordatorio as gr 
    inner join gestion_mascota as gm on gr.id_mascota_id=gm.id_mascota
    inner join gestion_cliente as gp on gp.id_cliente=gm.id_cliente_id 
    where gr.id_sucursal_id = id_sucu and gr.fecha=fech and gr.estado=true ;
end;
$$;


--
-- Name: fn_exportar_reporte_atenciones(integer, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_exportar_reporte_atenciones(sucursal integer, inicio date, fin date) RETURNS TABLE(id_atencion integer, nombre character varying, historia integer, monto_total numeric, entrada timestamp with time zone, salida timestamp with time zone, estado text, descripcion character varying, monto numeric)
    LANGUAGE plpgsql
    AS $$
declare
begin
	return query
		select ga.id_atencion,gm.nombre,gm.numero_historia,ga.monto_total,ga.entrada, 
        case when ga.salida!=ga.entrada  then ga.salida else null end as salida_e, 
        case when ga.estado=true then 'Atendido' else 'En curso' end as estado, gs.descripcion,dta.monto
        from gestion_atencion as ga 
        inner join gestion_detalle_atencion as dta on ga.id_atencion=dta.id_atencion_id 
        inner join gestion_servicio as gs on dta.id_servicio_id=gs.id_servicio 
        inner join gestion_mascota as gm on ga.id_mascota_id=gm.id_mascota 
        where ga.id_sucursal_id = sucursal and (CAST(ga.entrada as date)  between inicio and fin ) 
        order by ga.entrada;
end;
$$;


--
-- Name: fn_exportar_reporte_compras(integer, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_exportar_reporte_compras(sucursal integer, inicio date, fin date) RETURNS TABLE(documento character varying, numero text, razon_social character varying, fecha date, impuesto numeric, monto_total numeric, estado text, nombre character varying, unidad character varying, cantidad integer, precio numeric, subtotal numeric)
    LANGUAGE plpgsql
    AS $$
declare
begin
		return query
		select tpc.descripcion,(cc.serie||'-'||cc.numero) as documento,cp.razon_social,cc.fecha,cc.impuesto,cc.monto_total, 
		case when cc.estado=true then 'Realizada' else  'Anulada' end as estado, 
		pp.nombre,pum.descripcion,dtc.cantidad::integer,dtc.precio,dtc.subtotal from compras_compra as cc 
		inner join compras_detallecompra as dtc on cc.id_compra=dtc.id_compra_id 
		inner join compras_proveedor as cp on cp.id_proveedor=cc.id_proveedor_id 
		inner join productos_producto as pp on dtc.id_producto_id=pp.id_producto 
		inner join ventas_tipocomprobante as tpc on cc.id_tipo_comprobante_id=tpc.id_tipo_comprobante 
		inner join productos_unidadmedida as pum on pum.id_unidad_medida=pp.id_unidad_medida_id 
		where cc.id_sucursal_id=sucursal and cc.fecha between inicio and fin
		order by cc.fecha;
end;
$$;


--
-- Name: fn_exportar_reporte_producto_sucursal(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_exportar_reporte_producto_sucursal(sucursal integer) RETURNS TABLE(categ character varying, nombre character varying, descripcion text, precio numeric, stock integer, stockmin integer, unidad character varying, estado text)
    LANGUAGE plpgsql
    AS $$
declare
begin
	return query
	select pc.descripcion,pp.nombre, pp.descripcion, ps.precio,ps.stock, ps.stock_min,pu.descripcion, 
	case when pp.estado=true then 'Activo' else 'Inactivo' end as estado from productos_productosucursal as ps 
	inner join productos_producto as pp on pp.id_producto=ps.id_producto_id 
	inner join productos_categoria as pc on pp.id_categoria_id=pc.id_categoria 
	inner join productos_unidadmedida as pu on pp.id_unidad_medida_id=pu.id_unidad_medida 
	where ps.id_sucursal_id=sucursal
	order by pc.descripcion ;
end;
$$;


--
-- Name: fn_exportar_reporte_venta_sucursal(integer, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_exportar_reporte_venta_sucursal(sucursal integer, inicio date, fin date) RETURNS TABLE(comprobante character varying, documento text, cliente text, fecha date, tipopago character varying, igv numeric, montototal numeric, estado text, nombre character varying, unidad_medida character varying, cantidad smallint, precio numeric, subtotal numeric)
    LANGUAGE plpgsql
    AS $$
declare
begin
return query

select tpc.descripcion,(vv.serie||'-'||vv.numero) as documento,(c.nombre||' '||c.apellido) as cliente,vv.fecha,mt.descripcion,vv.igv, vv.monto_total,
case when vv.estado=1 then  'Realizada' else  'Anulada' end as estado,  
pp.nombre,pum.descripcion,dtv.cantidad,dtv.precio,dtv.subtotal from ventas_venta as vv 
inner join ventas_detalleventa as dtv on vv.id_venta=dtv.id_venta_id 
inner join gestion_cliente as c on c.id_cliente=vv.id_cliente_id 
inner join productos_producto as pp on dtv.id_producto_id=pp.id_producto 
inner join gestion_metodopago as mt on vv.id_metodo_pago_id=mt.id_metodo_pago 
inner join ventas_tipocomprobante as tpc on vv.id_tipo_comprobante_id=tpc.id_tipo_comprobante 
inner join productos_unidadmedida as pum on pum.id_unidad_medida=pp.id_unidad_medida_id 
where vv.id_sucursal_id=sucursal and vv.fecha between inicio and fin order by documento ;

end;
$$;


--
-- Name: fn_exportar_resumen_reporte_venta_sucursal(integer, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_exportar_resumen_reporte_venta_sucursal(sucursal integer, inicio date, fin date) RETURNS TABLE(status text, total bigint, suma numeric)
    LANGUAGE plpgsql
    AS $$
declare
begin
return query
select case when estado=1 then  'Realizada' else  'Anulada' end as estado, 
count(estado) as total, sum(monto_total) from ventas_venta 
where id_sucursal_id=sucursal and fecha between inicio and fin
group by estado;
end;
$$;


--
-- Name: fn_ganancia_mensual_antencion_sucursal(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_ganancia_mensual_antencion_sucursal(anio character varying, sucursal integer) RETURNS TABLE(mes integer, ganancia numeric)
    LANGUAGE plpgsql
    AS $$
declare
begin
		return query
		select EXTRACT(MONTH FROM salida )::int as mes, sum(monto_total)as ganancia_mensual from gestion_atencion 
		where EXTRACT(YEAR FROM salida )::varchar = anio and id_sucursal_id=sucursal
		group by EXTRACT(MONTH FROM salida ) 
		order by mes asc;
end;
$$;


--
-- Name: fn_ganancia_mensual_atencion(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_ganancia_mensual_atencion(anio character varying, usu character varying) RETURNS TABLE(mes integer, ganancia numeric)
    LANGUAGE plpgsql
    AS $$
declare
var_id_sucursal int;
begin
	select (us.id_sucursal) into var_id_sucursal from usuarios_usuario as us where us.username=usu;
	return query
	select EXTRACT(MONTH FROM salida )::int as mes, sum(monto_total)as ganancia_mensual from gestion_atencion 
	where EXTRACT(YEAR FROM salida )::varchar = anio and id_sucursal_id=var_id_sucursal
    group by EXTRACT(MONTH FROM salida ) 
    order by mes asc;
end;
$$;


--
-- Name: fn_ganancia_mensual_ventas_sucursal(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_ganancia_mensual_ventas_sucursal(anio character varying, sucursal integer) RETURNS TABLE(mes integer, ganancia numeric)
    LANGUAGE plpgsql
    AS $$
declare
begin
	return query
	select EXTRACT(MONTH FROM fecha )::int as mes, sum(monto_total)as ganancia_mensual from ventas_venta 
    where EXTRACT(YEAR FROM fecha )::varchar=anio and estado=1  and id_sucursal_id=sucursal
    group by EXTRACT(MONTH FROM fecha ) 
    order by mes asc ;
end;
$$;


--
-- Name: fn_ganancias_diaras_servicios(date, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_ganancias_diaras_servicios(fech date, usu character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
declare
rest decimal;
var_id_sucursal int;
begin
		select (us.id_sucursal) into var_id_sucursal from usuarios_usuario as us where us.username=usu;
		
		select sum(monto_total) into rest from gestion_atencion as g
		inner join usuarios_usuario as u on g.usuario_id=u.id
		inner join empresa_sucursal as es on u.id_sucursal=es.id_sucursal
		where CAST(g.entrada as date)  =fech and es.id_sucursal=var_id_sucursal ;
		
	return rest;
end;
$$;


--
-- Name: fn_ganancias_diaras_ventas(date, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_ganancias_diaras_ventas(fech date, usu character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
declare
rest decimal;
var_id_sucursal int;
begin
		select (us.id_sucursal) into var_id_sucursal from usuarios_usuario as us where us.username=usu;
		select sum(monto_total) into rest from ventas_venta as v
		inner join usuarios_usuario as u on v.id_usuario_id=u.id
        --where EXTRACT(YEAR FROM salida) ='2022'
		--select sum(monto_total) into rest from gestion_atencion as g
	where v.fecha=fech and v.estado=1 and u.id_sucursal=var_id_sucursal;
	--where CAST(g.salida as date)  =fech;
	
	return rest;
end;
$$;


--
-- Name: fn_historal_atencion_mascota(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_historal_atencion_mascota(id_masc integer) RETURNS TABLE(id_atencion integer, nombre character varying, descripcion character varying, monto numeric, salida timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select ga.id_atencion,gm.nombre, gs.descripcion, gd.monto,ga.salida 
	from gestion_detalle_atencion as gd
	inner join gestion_servicio as gs on gd.id_servicio_id=gs.id_servicio
	inner join gestion_atencion as ga on gd.id_atencion_id=ga.id_atencion 
	inner join gestion_mascota as gm on ga.id_mascota_id=gm.id_mascota
	where gm.id_mascota=id_masc
	order by ga.salida;
end;
$$;


--
-- Name: fn_listar_atencion(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_listar_atencion(sucursal integer) RETURNS TABLE(atencion integer, numero_atencion bigint, historia integer, nombre character varying, total numeric, entrada timestamp with time zone, salida timestamp with time zone, estado boolean)
    LANGUAGE plpgsql
    AS $$
declare
begin
	return query
	select ga.id_atencion,ga.numero_atencion,gm.numero_historia,gm.nombre,ga.monto_total,ga.entrada, 
    case when ga.estado=true  then ga.salida else null end as salida_e, ga.estado
    from gestion_atencion as ga inner join gestion_mascota as gm on ga.id_mascota_id=gm.id_mascota
    where ga.id_sucursal_id=sucursal order by estado;
end;
$$;


--
-- Name: fn_listar_compras(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_listar_compras(sucursal integer) RETURNS TABLE(id_c integer, razon_social_c character varying, documento_c character varying, num_doc_c text, total_c numeric, impuesto_c numeric, fecha_c date, estado_c boolean, id_usu_c bigint, id_provee_c integer, id_tc_c integer)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select cc.id_compra,cp.razon_social ,tc.descripcion, cc.serie||'-'||cc.numero as num_doc, 
	cc.monto_total, cc.impuesto, cc.fecha, cc.estado, usu.id, cp.id_proveedor,tc.id_tipo_comprobante
	from compras_compra as cc
	inner join ventas_tipocomprobante as tc on cc.id_tipo_comprobante_id=tc.id_tipo_comprobante
	inner join compras_proveedor as cp on cc.id_proveedor_id=cp.id_proveedor
	inner join usuarios_usuario as usu on cc.id_usuario_id=usu.id
	where cc.id_sucursal_id=sucursal;
end;
$$;


--
-- Name: fn_listar_producto_empresa(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_listar_producto_empresa(id_empresa integer) RETURNS TABLE(id_producto integer, nombre character varying, descripcion text, id_categoria_id integer, id_unidad_medida_id integer, estado boolean, categoria character varying, unidadmedida character varying)
    LANGUAGE plpgsql
    AS $$
declare
begin
	return query
	SELECT p.id_producto,
    p.nombre,
    p.descripcion,
    p.id_categoria_id,
    p.id_unidad_medida_id,
    p.estado,
    pc.descripcion AS categoria,
    pu.descripcion AS unidadmedida
   FROM productos_producto p
     JOIN productos_categoria pc ON p.id_categoria_id = pc.id_categoria
     JOIN productos_unidadmedida pu ON p.id_unidad_medida_id = pu.id_unidad_medida
	 where p.id_empresa_id =id_empresa;
end;
$$;


--
-- Name: fn_listar_producto_sucursal(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_listar_producto_sucursal(sucursal integer) RETURNS TABLE(id_prod_duc integer, id_prod integer, nombre character varying, id_unid_med integer, unidad_med character varying, id_categ integer, categ character varying, precio numeric, stock integer, stockmin integer, estado boolean, id_sucu integer, razonsocial character varying)
    LANGUAGE plpgsql
    AS $$
declare
begin
	return query
	select ps.id_producto_sucursal,ps.id_producto_id,p.nombre, 
	p.id_unidad_medida_id,um.descripcion,p.id_categoria_id,c.descripcion, 
	ps.precio,ps.stock,ps.stock_min,ps.estado,ps.id_sucursal_id,s.razon_social 
	from productos_productosucursal as ps 
	inner join productos_producto as p on ps.id_producto_id=p.id_producto 
	inner join empresa_sucursal as s on ps.id_sucursal_id=s.id_sucursal 
	inner join productos_unidadmedida as um on p.id_unidad_medida_id=um.id_unidad_medida 
	inner join productos_categoria as c on p.id_categoria_id=c.id_categoria where s.id_sucursal=sucursal;
end;
$$;


--
-- Name: fn_listar_usuarios_empresa(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_listar_usuarios_empresa(id_sucu integer) RETURNS TABLE(id bigint, username character varying, first_name character varying, last_name character varying, email character varying, is_active boolean, id_sucursal integer)
    LANGUAGE plpgsql
    AS $$
declare
id_empresa_usu integer;
begin
	
	select id_empresa_id into id_empresa_usu  from empresa_sucursal as su where su.id_sucursal = id_sucu;
	return query
	SELECT u.id,u.username,u.first_name,u.last_name,u.email,u.is_active,
	u.id_sucursal
	FROM usuarios_usuario as u
	inner join empresa_sucursal as eu on u.id_sucursal = eu.id_sucursal
	inner join empresa_empresa as em on eu.id_empresa_id = em.id
	where em.id =id_empresa_usu;
end;
$$;


--
-- Name: fn_listar_ventas_sucursal(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_listar_ventas_sucursal(sucursal integer) RETURNS TABLE(id_venta integer, tipo_comprobante character varying, documento text, fecha date, monto_total numeric, cliente text, metodo_pago character varying, estado integer)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select vv.id_venta,vtd.descripcion,(vv.serie ||'-'|| vv.numero) as documento,vv.fecha,vv.monto_total,
	(gc.nombre ||' '||gc.apellido) as cliente, gmp.descripcion, vv.estado
	from ventas_venta as vv
	inner join ventas_tipocomprobante as vtd on vv.id_tipo_comprobante_id=vtd.id_tipo_comprobante
	inner join gestion_cliente as gc on vv.id_cliente_id=gc.id_cliente
	inner join gestion_metodopago as gmp on vv.id_metodo_pago_id=gmp.id_metodo_pago
	where vv.id_sucursal_id=sucursal
	order by vv.fecha desc;
end;
$$;


--
-- Name: fn_mejores_productos_ventas(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_mejores_productos_ventas(anio character varying, sucursal integer) RETURNS TABLE(producto character varying, cantidad integer)
    LANGUAGE plpgsql
    AS $$
declare
begin
		return query
		select pp.nombre, sum(dtv.cantidad)::int from ventas_detalleventa as dtv 
    	inner join productos_producto as pp on dtv.id_producto_id=pp.id_producto 
    	inner join ventas_venta as vv on vv.id_venta=dtv.id_venta_id 
    	where vv.estado=1 and to_char(vv.fecha, 'YYYY-MM')::varchar= anio and vv.id_sucursal_id=sucursal 
		group by pp.nombre limit 5;
end;
$$;


--
-- Name: fn_productos_agotarse(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_productos_agotarse(usu character varying) RETURNS TABLE(nom character varying, stk integer)
    LANGUAGE plpgsql
    AS $$
declare
id_sucu int;
begin
	select id_sucursal into id_sucu from usuarios_usuario where username=usu;
	return query
	select pp.nombre,ps.stock from productos_productosucursal as ps
	inner join productos_producto as pp on ps.id_producto_id=pp.id_producto
	where ps.id_sucursal_id=id_sucu and ps.stock<ps.stock_min and ps.estado=true;
end;
$$;


--
-- Name: fn_recordatorios_pendientes(date, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_recordatorios_pendientes(fech date, usu character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
id_sucu integer;
cantidad integer;
begin
	select us.id_sucursal into id_sucu  from usuarios_usuario as us where us.username=usu;
	select count(*) into cantidad
    from gestion_recordatorio
    where fecha=fech and estado=true and id_sucursal_id = id_sucu;
	return cantidad;
end;
$$;


--
-- Name: fn_servicios_atendidos_hoy(date, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_servicios_atendidos_hoy(fecha date, usu character varying) RETURNS TABLE(numero bigint)
    LANGUAGE plpgsql
    AS $$
declare
var_id_sucursal int;
begin
	select (us.id_sucursal) into var_id_sucursal from usuarios_usuario as us where us.username=usu;
	return query
	select count(*) as cantidad  from gestion_atencion
	where id_sucursal_id=var_id_sucursal 
	and (EXTRACT(YEAR FROM salida )||'/'|| EXTRACT(MONTH FROM salida )||'/'|| EXTRACT(DAY FROM salida ))::date=fecha
	and  entrada != salida ;
end;
$$;


--
-- Name: fn_servicios_mas_solicitados(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_servicios_mas_solicitados("mes_año" character varying, usu character varying) RETURNS TABLE(descripcion character varying, cantidad bigint)
    LANGUAGE plpgsql
    AS $$
declare
var_id_sucursal int;
begin
	select (us.id_sucursal) into var_id_sucursal from usuarios_usuario as us where us.username=usu;
	return query
		select 
			(case when gs.descripcion like '%vacuna%' then 'vacuna' 
			else gs.descripcion end) as descripcion ,
			count(case when gs.descripcion like '%vacuna%' then 'vacuna' 
			else gs.descripcion end) as cantidad from gestion_detalle_atencion as gd
		inner join gestion_servicio as gs on gd.id_servicio_id=gs.id_servicio
		inner join gestion_atencion as ga on ga.id_atencion=gd.id_atencion_id
		where  to_char(ga.salida, 'YYYY-MM') = mes_año and ga.id_sucursal_id=var_id_sucursal
		group by (case when gs.descripcion like '%vacuna%' then 'vacuna' 
			else gs.descripcion end)
		order by cantidad desc
		limit 3;
end;
$$;


--
-- Name: fn_servicios_mas_solicitados_sucursal(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_servicios_mas_solicitados_sucursal("mes_año" character varying, sucursal integer) RETURNS TABLE(descripcion character varying, cantidad bigint)
    LANGUAGE plpgsql
    AS $$
declare

begin
	return query
		select 
			(case when gs.descripcion like '%vacuna%' then 'vacuna' 
			else gs.descripcion end) as descripcion ,
			count(case when gs.descripcion like '%vacuna%' then 'vacuna' 
			else gs.descripcion end) as cantidad from gestion_detalle_atencion as gd
		inner join gestion_servicio as gs on gd.id_servicio_id=gs.id_servicio
		inner join gestion_atencion as ga on ga.id_atencion=gd.id_atencion_id
		where  to_char(ga.salida, 'YYYY-MM') = mes_año and ga.id_sucursal_id=sucursal
		group by (case when gs.descripcion like '%vacuna%' then 'vacuna' 
			else gs.descripcion end)
		order by cantidad desc
		limit 3;
end;
$$;


--
-- Name: fn_ultimas_atenciones_mascota(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_ultimas_atenciones_mascota(id_masc integer) RETURNS TABLE(descripcion character varying)
    LANGUAGE plpgsql
    AS $$
begin 
	return query
	select distinct(case when se.descripcion like '%vacuna%' then 'vacuna' 
	else se.descripcion end) as descripcion from gestion_detalle_atencion as gda
	inner join gestion_servicio as se on gda.id_servicio_id=se.id_servicio
	inner join gestion_atencion as gat on gat.id_atencion=gda.id_atencion_id
	where gat.id_mascota_id=id_masc;
end;
$$;


--
-- Name: fn_utlima_atencion_servicio(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_utlima_atencion_servicio(id_masc integer, serv character varying) RETURNS TABLE(descripcion character varying, fecha date)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select se.descripcion,(EXTRACT(YEAR FROM ga.entrada )||'/'|| EXTRACT(MONTH FROM ga.entrada )||'/'|| EXTRACT(DAY FROM ga.entrada ))::date as fecha 
	from  gestion_atencion as ga
	inner join gestion_detalle_atencion as gda on ga.id_atencion=gda.id_atencion_id
	inner join gestion_servicio as se on gda.id_servicio_id=se.id_servicio
	inner join gestion_mascota as ma on ga.id_mascota_id=ma.id_mascota
	where ma.id_mascota=id_masc and se.descripcion like ('%'||serv||'%')
	order by fecha desc
	limit 1;
end;
$$;



CREATE VIEW public.view_listar_correlativo_empresa AS
 SELECT vc.id_correlativo,
    tc.id_tipo_comprobante,
    tc.descripcion,
    vc.serie,
    vc.primer_numero,
    vc.ultimo_numero_registrado,
    vc.max_correlativo,
    vc.id_empresa_id AS id_empresa
   FROM (public.ventas_correlativo vc
     JOIN public.ventas_tipocomprobante tc ON ((vc.id_tipo_comprobante_id = tc.id_tipo_comprobante)));


--
-- Name: view_listar_permisos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_listar_permisos AS
 SELECT ap.codename,
    ap.name
   FROM (public.auth_permission ap
     JOIN public.django_content_type ct ON ((ap.content_type_id = ct.id)))
  WHERE (((ct.app_label)::text !~~ 'auth'::text) AND ((ct.app_label)::text !~~ 'admin'::text) AND ((ct.app_label)::text !~~ 'contenttypes'::text) AND ((ct.app_label)::text !~~ 'sessions'::text) AND ((ct.app_label)::text !~~ 'report'::text) AND ((ct.model)::text !~~ 'metodopago'::text) AND ((ct.model)::text !~~ 'tipodocumento'::text) AND ((ct.model)::text !~~ 'parametro'::text));


--
-- Name: view_listar_permisos_usuario; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_listar_permisos_usuario AS
 SELECT ap.codename,
    usp.usuario_id
   FROM (public.usuarios_usuario_user_permissions usp
     JOIN public.auth_permission ap ON ((usp.permission_id = ap.id)));


--
-- Name: vw_exportar_reporte_lista_mascota; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_exportar_reporte_lista_mascota AS
 SELECT gm.numero_historia,
    ga.descripcion AS animal,
    gr.descripcion AS raza,
    gm.nombre,
    gm.edad,
        CASE
            WHEN (gm.sexo = 1) THEN 'Macho'::text
            ELSE 'Hembra'::text
        END AS sexo,
    gm.color,
    gm.peso,
    (((gp.nombre)::text || ' '::text) || (gp.apellido)::text) AS cliente,
    gm.id_sucursal_id AS id_sucursal
   FROM ((((public.gestion_mascota gm
     JOIN public.gestion_raza gr ON ((gm.id_raza_id = gr.id_raza)))
     JOIN public.gestion_animal ga ON ((gr.id_animal_id = ga.id_animal)))
     JOIN public.gestion_cliente gp ON ((gm.id_cliente_id = gp.id_cliente)))
     JOIN public.empresa_sucursal eu ON ((gm.id_sucursal_id = eu.id_sucursal)))
  ORDER BY gm.numero_historia;


--
-- Name: vw_exportar_reporte_producto; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_exportar_reporte_producto AS
 SELECT pc.descripcion AS categria,
    pp.nombre,
    pp.descripcion,
    pu.descripcion AS unidad,
        CASE
            WHEN (pp.estado = true) THEN 'Activo'::text
            ELSE 'Inactivo'::text
        END AS estado
   FROM ((public.productos_producto pp
     JOIN public.productos_categoria pc ON ((pp.id_categoria_id = pc.id_categoria)))
     JOIN public.productos_unidadmedida pu ON ((pp.id_unidad_medida_id = pu.id_unidad_medida)))
  ORDER BY pc.descripcion;


--
-- Name: vw_exportar_reporte_servicio; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_exportar_reporte_servicio AS
 SELECT
        CASE
            WHEN (gs.id_animal = 0) THEN 'General'::character varying
            ELSE ga.descripcion
        END AS animal,
    gs.descripcion,
    gs.precio,
        CASE
            WHEN (gs.estado = true) THEN 'Activo'::text
            ELSE 'Inactivo'::text
        END AS estado,
    gs.id_sucursal_id AS id_sucursal
   FROM (public.gestion_servicio gs
     LEFT JOIN public.gestion_animal ga ON ((gs.id_animal = ga.id_animal)))
  ORDER BY
        CASE
            WHEN (gs.id_animal = 0) THEN 'General'::character varying
            ELSE ga.descripcion
        END;


--
-- Name: vw_listar_mascota; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_listar_mascota AS
 SELECT gm.id_mascota,
    gm.numero_historia,
    ga.descripcion AS animal,
    gr.descripcion AS raza,
    gm.nombre,
    gm.edad,
    gm.sexo,
    gm.color,
    gm.peso,
    gm.estado,
    gc.numero_documento_cliente,
    ga.id_animal,
    gr.id_raza,
    gc.id_cliente,
    ee.id AS id_empresa
   FROM ((((public.gestion_mascota gm
     JOIN public.gestion_raza gr ON ((gm.id_raza_id = gr.id_raza)))
     JOIN public.gestion_animal ga ON ((gr.id_animal_id = ga.id_animal)))
     JOIN public.gestion_cliente gc ON ((gm.id_cliente_id = gc.id_cliente)))
     JOIN public.empresa_empresa ee ON ((gm.id_empresa_id = ee.id)));


--
-- Name: vw_listar_producto; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_listar_producto AS
 SELECT p.id_producto,
    p.nombre,
    p.descripcion,
    p.id_categoria_id,
    p.id_unidad_medida_id,
    p.estado,
    pc.descripcion AS categoria,
    pu.descripcion AS unidadmedida
   FROM ((public.productos_producto p
     JOIN public.productos_categoria pc ON ((p.id_categoria_id = pc.id_categoria)))
     JOIN public.productos_unidadmedida pu ON ((p.id_unidad_medida_id = pu.id_unidad_medida)));


--
-- Name: vw_listar_proveedor; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_listar_proveedor AS
 SELECT cp.id_proveedor,
    cp.numero_documento_proveedor,
    cp.razon_social,
    cp.telefono_proveedor,
    cp.telefono_contacto,
    cp.direccion,
    cp.estado,
    gtd.id_tipo_documento,
    gtd.descripcion,
    cp.id_empresa_id AS id_empresa
   FROM (public.compras_proveedor cp
     JOIN public.gestion_tipodocumento gtd ON ((cp.id_tipo_documento_id = gtd.id_tipo_documento)));


--
-- Name: vw_listar_raza; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_listar_raza AS
 SELECT gr.id_raza,
    ga.id_animal AS codigo_animal,
    ga.descripcion AS animal,
    gr.descripcion AS raza,
    gr.id_empresa_id AS id_empresa
   FROM (public.gestion_raza gr
     JOIN public.gestion_animal ga ON ((gr.id_animal_id = ga.id_animal)))
  ORDER BY gr.id_raza;


--
-- Name: vw_listar_recordatorio; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_listar_recordatorio AS
 SELECT gr.id_recordatorio,
    gm.nombre,
    gs.descripcion,
    gr.fecha,
    gr.comentario,
    gr.estado,
    gm.numero_historia,
    gs.id_servicio,
    gr.id_empresa_id AS id_empresa,
    gr.id_sucursal_id AS id_sucursal,
    gm.id_mascota
   FROM ((public.gestion_recordatorio gr
     JOIN public.gestion_servicio gs ON ((gr.id_servicio_id = gs.id_servicio)))
     JOIN public.gestion_mascota gm ON ((gr.id_mascota_id = gm.id_mascota)))
  ORDER BY gr.fecha, (gr.estado = true);


--
-- Name: vw_listar_servicio; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_listar_servicio AS
 SELECT gs.id_servicio,
    gs.descripcion,
        CASE
            WHEN (gs.id_animal = 0) THEN 'General'::character varying
            ELSE ga.descripcion
        END AS animal,
    gs.precio,
    gs.estado,
    gs.id_animal,
    gs.id_sucursal_id AS id_sucursal
   FROM (public.gestion_servicio gs
     LEFT JOIN public.gestion_animal ga ON ((gs.id_animal = ga.id_animal)))
  ORDER BY
        CASE
            WHEN (gs.id_animal = 0) THEN 'General'::character varying
            ELSE ga.descripcion
        END;


--
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: -
--


