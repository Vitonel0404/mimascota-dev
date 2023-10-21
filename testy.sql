PGDMP         /                {            vettypet %   12.16 (Ubuntu 12.16-0ubuntu0.20.04.1) #   14.9 (Ubuntu 14.9-0ubuntu0.22.04.1) �   �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    19754    vettypet    DATABASE     Y   CREATE DATABASE vettypet WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'C.UTF-8';
    DROP DATABASE vettypet;
                postgres    false                       1255    19755 !   fn_buscar_detalle_compra(integer)    FUNCTION     �  CREATE FUNCTION public.fn_buscar_detalle_compra(id_compra integer) RETURNS TABLE(nombre_p character varying, precio_p numeric, cantidad_p smallint, subtotal_p numeric)
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
 B   DROP FUNCTION public.fn_buscar_detalle_compra(id_compra integer);
       public          postgres    false                       1255    19756     fn_buscar_detalle_venta(integer)    FUNCTION     �  CREATE FUNCTION public.fn_buscar_detalle_venta(id_venta integer) RETURNS TABLE(venta_id integer, nombre_p character varying, precio_p numeric, cantidad_p smallint, subtotal_p numeric)
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
 @   DROP FUNCTION public.fn_buscar_detalle_venta(id_venta integer);
       public          postgres    false                       1255    19757 7   fn_buscar_producto_sucursal(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.fn_buscar_producto_sucursal(producto character varying, sucursal integer) RETURNS TABLE(id_prod_suc integer, precio numeric, stock integer, stockmin integer, estado boolean, id_prod integer, id_sucursal integer, prod_id integer, nombre character varying, descripcion text, estad boolean, id_categ integer, id_empresa bigint, id_unid_med integer)
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
 `   DROP FUNCTION public.fn_buscar_producto_sucursal(producto character varying, sucursal integer);
       public          postgres    false                       1255    19758 6   fn_buscar_recordatorio_mascota(integer, date, integer)    FUNCTION     u  CREATE FUNCTION public.fn_buscar_recordatorio_mascota(historia integer, fech date, id_empresa integer) RETURNS TABLE(descripcion character varying, fecha date, comentario text, id_recordatorio integer)
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
 f   DROP FUNCTION public.fn_buscar_recordatorio_mascota(historia integer, fech date, id_empresa integer);
       public          postgres    false                       1255    19759 &   fn_consultar_detalle_atencion(integer)    FUNCTION     y  CREATE FUNCTION public.fn_consultar_detalle_atencion(atencion integer) RETURNS TABLE(nombre character varying, monto numeric)
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
 F   DROP FUNCTION public.fn_consultar_detalle_atencion(atencion integer);
       public          postgres    false                       1255    19760 <   fn_correos_recordatorios_pendientes(date, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_correos_recordatorios_pendientes(fech date, usu character varying) RETURNS TABLE(correo character varying, cliente character varying, mascota character varying)
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
 \   DROP FUNCTION public.fn_correos_recordatorios_pendientes(fech date, usu character varying);
       public          postgres    false            !           1255    19761 3   fn_exportar_reporte_atenciones(integer, date, date)    FUNCTION     .  CREATE FUNCTION public.fn_exportar_reporte_atenciones(sucursal integer, inicio date, fin date) RETURNS TABLE(id_atencion integer, nombre character varying, historia integer, monto_total numeric, entrada timestamp with time zone, salida timestamp with time zone, estado text, descripcion character varying, monto numeric)
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
 ^   DROP FUNCTION public.fn_exportar_reporte_atenciones(sucursal integer, inicio date, fin date);
       public          postgres    false            0           1255    19762 0   fn_exportar_reporte_compras(integer, date, date)    FUNCTION     �  CREATE FUNCTION public.fn_exportar_reporte_compras(sucursal integer, inicio date, fin date) RETURNS TABLE(documento character varying, numero text, razon_social character varying, fecha date, impuesto numeric, monto_total numeric, estado text, nombre character varying, unidad character varying, cantidad integer, precio numeric, subtotal numeric)
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
 [   DROP FUNCTION public.fn_exportar_reporte_compras(sucursal integer, inicio date, fin date);
       public          postgres    false            1           1255    19763 .   fn_exportar_reporte_producto_sucursal(integer)    FUNCTION     ;  CREATE FUNCTION public.fn_exportar_reporte_producto_sucursal(sucursal integer) RETURNS TABLE(categ character varying, nombre character varying, descripcion text, precio numeric, stock integer, stockmin integer, unidad character varying, estado text)
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
 N   DROP FUNCTION public.fn_exportar_reporte_producto_sucursal(sucursal integer);
       public          postgres    false            D           1255    20543 7   fn_exportar_reporte_venta_sucursal(integer, date, date)    FUNCTION     #  CREATE FUNCTION public.fn_exportar_reporte_venta_sucursal(sucursal integer, inicio date, fin date) RETURNS TABLE(comprobante character varying, documento text, cliente text, fecha date, tipopago character varying, igv numeric, montototal numeric, estado text, nombre character varying, unidad_medida character varying, cantidad smallint, precio numeric, subtotal numeric)
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
 b   DROP FUNCTION public.fn_exportar_reporte_venta_sucursal(sucursal integer, inicio date, fin date);
       public          postgres    false            2           1255    19765 ?   fn_exportar_resumen_reporte_venta_sucursal(integer, date, date)    FUNCTION     �  CREATE FUNCTION public.fn_exportar_resumen_reporte_venta_sucursal(sucursal integer, inicio date, fin date) RETURNS TABLE(status text, total bigint, suma numeric)
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
 j   DROP FUNCTION public.fn_exportar_resumen_reporte_venta_sucursal(sucursal integer, inicio date, fin date);
       public          postgres    false            3           1255    19766 B   fn_ganancia_mensual_antencion_sucursal(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.fn_ganancia_mensual_antencion_sucursal(anio character varying, sucursal integer) RETURNS TABLE(mes integer, ganancia numeric)
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
 g   DROP FUNCTION public.fn_ganancia_mensual_antencion_sucursal(anio character varying, sucursal integer);
       public          postgres    false            4           1255    19767 B   fn_ganancia_mensual_atencion(character varying, character varying)    FUNCTION     K  CREATE FUNCTION public.fn_ganancia_mensual_atencion(anio character varying, usu character varying) RETURNS TABLE(mes integer, ganancia numeric)
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
 b   DROP FUNCTION public.fn_ganancia_mensual_atencion(anio character varying, usu character varying);
       public          postgres    false            5           1255    19768 ?   fn_ganancia_mensual_ventas_sucursal(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.fn_ganancia_mensual_ventas_sucursal(anio character varying, sucursal integer) RETURNS TABLE(mes integer, ganancia numeric)
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
 d   DROP FUNCTION public.fn_ganancia_mensual_ventas_sucursal(anio character varying, sucursal integer);
       public          postgres    false            6           1255    19769 6   fn_ganancias_diaras_servicios(date, character varying)    FUNCTION     =  CREATE FUNCTION public.fn_ganancias_diaras_servicios(fech date, usu character varying) RETURNS numeric
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
 V   DROP FUNCTION public.fn_ganancias_diaras_servicios(fech date, usu character varying);
       public          postgres    false                        1255    19770 3   fn_ganancias_diaras_ventas(date, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_ganancias_diaras_ventas(fech date, usu character varying) RETURNS numeric
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
 S   DROP FUNCTION public.fn_ganancias_diaras_ventas(fech date, usu character varying);
       public          postgres    false            "           1255    19771 %   fn_historal_atencion_mascota(integer)    FUNCTION     }  CREATE FUNCTION public.fn_historal_atencion_mascota(id_masc integer) RETURNS TABLE(id_atencion integer, nombre character varying, descripcion character varying, monto numeric, salida timestamp with time zone)
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
 D   DROP FUNCTION public.fn_historal_atencion_mascota(id_masc integer);
       public          postgres    false            #           1255    19772    fn_listar_atencion(integer)    FUNCTION     �  CREATE FUNCTION public.fn_listar_atencion(sucursal integer) RETURNS TABLE(atencion integer, numero_atencion bigint, historia integer, nombre character varying, total numeric, entrada timestamp with time zone, salida timestamp with time zone, estado boolean)
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
 ;   DROP FUNCTION public.fn_listar_atencion(sucursal integer);
       public          postgres    false            7           1255    19773    fn_listar_compras(integer)    FUNCTION     B  CREATE FUNCTION public.fn_listar_compras(sucursal integer) RETURNS TABLE(id_c integer, razon_social_c character varying, documento_c character varying, num_doc_c text, total_c numeric, impuesto_c numeric, fecha_c date, estado_c boolean, id_usu_c bigint, id_provee_c integer, id_tc_c integer)
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
 :   DROP FUNCTION public.fn_listar_compras(sucursal integer);
       public          postgres    false            8           1255    19774 #   fn_listar_producto_empresa(integer)    FUNCTION     �  CREATE FUNCTION public.fn_listar_producto_empresa(id_empresa integer) RETURNS TABLE(id_producto integer, nombre character varying, descripcion text, id_categoria_id integer, id_unidad_medida_id integer, estado boolean, categoria character varying, unidadmedida character varying)
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
 E   DROP FUNCTION public.fn_listar_producto_empresa(id_empresa integer);
       public          postgres    false            9           1255    19775 $   fn_listar_producto_sucursal(integer)    FUNCTION     �  CREATE FUNCTION public.fn_listar_producto_sucursal(sucursal integer) RETURNS TABLE(id_prod_duc integer, id_prod integer, nombre character varying, id_unid_med integer, unidad_med character varying, id_categ integer, categ character varying, precio numeric, stock integer, stockmin integer, estado boolean, id_sucu integer, razonsocial character varying)
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
 D   DROP FUNCTION public.fn_listar_producto_sucursal(sucursal integer);
       public          postgres    false            :           1255    19776 #   fn_listar_usuarios_empresa(integer)    FUNCTION     �  CREATE FUNCTION public.fn_listar_usuarios_empresa(id_sucu integer) RETURNS TABLE(id bigint, username character varying, first_name character varying, last_name character varying, email character varying, is_active boolean, id_sucursal integer)
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
 B   DROP FUNCTION public.fn_listar_usuarios_empresa(id_sucu integer);
       public          postgres    false            ;           1255    19777 "   fn_listar_ventas_sucursal(integer)    FUNCTION     '  CREATE FUNCTION public.fn_listar_ventas_sucursal(sucursal integer) RETURNS TABLE(id_venta integer, tipo_comprobante character varying, documento text, fecha date, monto_total numeric, cliente text, metodo_pago character varying, estado integer)
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
 B   DROP FUNCTION public.fn_listar_ventas_sucursal(sucursal integer);
       public          postgres    false            <           1255    19778 7   fn_mejores_productos_ventas(character varying, integer)    FUNCTION     A  CREATE FUNCTION public.fn_mejores_productos_ventas(anio character varying, sucursal integer) RETURNS TABLE(producto character varying, cantidad integer)
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
 \   DROP FUNCTION public.fn_mejores_productos_ventas(anio character varying, sucursal integer);
       public          postgres    false            =           1255    19779 (   fn_productos_agotarse(character varying)    FUNCTION     �  CREATE FUNCTION public.fn_productos_agotarse(usu character varying) RETURNS TABLE(nom character varying, stk integer)
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
 C   DROP FUNCTION public.fn_productos_agotarse(usu character varying);
       public          postgres    false            >           1255    19780 4   fn_recordatorios_pendientes(date, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_recordatorios_pendientes(fech date, usu character varying) RETURNS integer
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
 T   DROP FUNCTION public.fn_recordatorios_pendientes(fech date, usu character varying);
       public          postgres    false            ?           1255    19781 3   fn_servicios_atendidos_hoy(date, character varying)    FUNCTION       CREATE FUNCTION public.fn_servicios_atendidos_hoy(fecha date, usu character varying) RETURNS TABLE(numero bigint)
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
 T   DROP FUNCTION public.fn_servicios_atendidos_hoy(fecha date, usu character varying);
       public          postgres    false            @           1255    19782 B   fn_servicios_mas_solicitados(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_servicios_mas_solicitados("mes_año" character varying, usu character varying) RETURNS TABLE(descripcion character varying, cantidad bigint)
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
 h   DROP FUNCTION public.fn_servicios_mas_solicitados("mes_año" character varying, usu character varying);
       public          postgres    false            A           1255    19783 A   fn_servicios_mas_solicitados_sucursal(character varying, integer)    FUNCTION     U  CREATE FUNCTION public.fn_servicios_mas_solicitados_sucursal("mes_año" character varying, sucursal integer) RETURNS TABLE(descripcion character varying, cantidad bigint)
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
 l   DROP FUNCTION public.fn_servicios_mas_solicitados_sucursal("mes_año" character varying, sucursal integer);
       public          postgres    false            B           1255    19784 &   fn_ultimas_atenciones_mascota(integer)    FUNCTION     �  CREATE FUNCTION public.fn_ultimas_atenciones_mascota(id_masc integer) RETURNS TABLE(descripcion character varying)
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
 E   DROP FUNCTION public.fn_ultimas_atenciones_mascota(id_masc integer);
       public          postgres    false            C           1255    19785 7   fn_utlima_atencion_servicio(integer, character varying)    FUNCTION     �  CREATE FUNCTION public.fn_utlima_atencion_servicio(id_masc integer, serv character varying) RETURNS TABLE(descripcion character varying, fecha date)
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
 [   DROP FUNCTION public.fn_utlima_atencion_servicio(id_masc integer, serv character varying);
       public          postgres    false            �            1259    19786 
   auth_group    TABLE     f   CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);
    DROP TABLE public.auth_group;
       public         heap    postgres    false            �            1259    19789    auth_group_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.auth_group_id_seq;
       public          postgres    false    202            �           0    0    auth_group_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;
          public          postgres    false    203            �            1259    19791    auth_group_permissions    TABLE     �   CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);
 *   DROP TABLE public.auth_group_permissions;
       public         heap    postgres    false            �            1259    19794    auth_group_permissions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.auth_group_permissions_id_seq;
       public          postgres    false    204            �           0    0    auth_group_permissions_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;
          public          postgres    false    205            �            1259    19796    auth_permission    TABLE     �   CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);
 #   DROP TABLE public.auth_permission;
       public         heap    postgres    false            �            1259    19799    auth_permission_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.auth_permission_id_seq;
       public          postgres    false    206            �           0    0    auth_permission_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;
          public          postgres    false    207            �            1259    19801    compras_compra    TABLE     �  CREATE TABLE public.compras_compra (
    id_compra integer NOT NULL,
    serie character varying(7) NOT NULL,
    numero integer NOT NULL,
    impuesto numeric(8,2) NOT NULL,
    monto_total numeric(8,2) NOT NULL,
    fecha date NOT NULL,
    estado boolean NOT NULL,
    id_proveedor_id integer NOT NULL,
    id_sucursal_id integer NOT NULL,
    id_tipo_comprobante_id integer NOT NULL,
    id_usuario_id bigint NOT NULL,
    fecha_registro date
);
 "   DROP TABLE public.compras_compra;
       public         heap    postgres    false            �            1259    19804    compras_detallecompra    TABLE     Q  CREATE TABLE public.compras_detallecompra (
    id_detalle_compra integer NOT NULL,
    precio numeric(5,2) NOT NULL,
    cantidad smallint NOT NULL,
    subtotal numeric(8,2) NOT NULL,
    id_compra_id integer NOT NULL,
    id_producto_id integer NOT NULL,
    CONSTRAINT compras_detallecompra_cantidad_check CHECK ((cantidad >= 0))
);
 )   DROP TABLE public.compras_detallecompra;
       public         heap    postgres    false            �            1259    19808 +   compras_detallecompra_id_detalle_compra_seq    SEQUENCE     �   CREATE SEQUENCE public.compras_detallecompra_id_detalle_compra_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 B   DROP SEQUENCE public.compras_detallecompra_id_detalle_compra_seq;
       public          postgres    false    209            �           0    0 +   compras_detallecompra_id_detalle_compra_seq    SEQUENCE OWNED BY     {   ALTER SEQUENCE public.compras_detallecompra_id_detalle_compra_seq OWNED BY public.compras_detallecompra.id_detalle_compra;
          public          postgres    false    210            �            1259    19810    compras_proveedor    TABLE     �  CREATE TABLE public.compras_proveedor (
    id_proveedor integer NOT NULL,
    numero_documento_proveedor character varying(11) NOT NULL,
    razon_social character varying(150) NOT NULL,
    telefono_proveedor character varying(9),
    telefono_contacto character varying(9),
    direccion character varying(150),
    estado boolean NOT NULL,
    id_tipo_documento_id integer NOT NULL,
    id_empresa_id bigint
);
 %   DROP TABLE public.compras_proveedor;
       public         heap    postgres    false            �            1259    19813 "   compras_proveedor_id_proveedor_seq    SEQUENCE     �   CREATE SEQUENCE public.compras_proveedor_id_proveedor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.compras_proveedor_id_proveedor_seq;
       public          postgres    false    211            �           0    0 "   compras_proveedor_id_proveedor_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.compras_proveedor_id_proveedor_seq OWNED BY public.compras_proveedor.id_proveedor;
          public          postgres    false    212            �            1259    19815    django_admin_log    TABLE     �  CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id bigint NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);
 $   DROP TABLE public.django_admin_log;
       public         heap    postgres    false            �            1259    19822    django_admin_log_id_seq    SEQUENCE     �   CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.django_admin_log_id_seq;
       public          postgres    false    213            �           0    0    django_admin_log_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;
          public          postgres    false    214            �            1259    19824    django_content_type    TABLE     �   CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);
 '   DROP TABLE public.django_content_type;
       public         heap    postgres    false            �            1259    19827    django_content_type_id_seq    SEQUENCE     �   CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.django_content_type_id_seq;
       public          postgres    false    215            �           0    0    django_content_type_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;
          public          postgres    false    216            �            1259    19829    django_migrations    TABLE     �   CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);
 %   DROP TABLE public.django_migrations;
       public         heap    postgres    false            �            1259    19835    django_migrations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.django_migrations_id_seq;
       public          postgres    false    217            �           0    0    django_migrations_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;
          public          postgres    false    218            �            1259    19837    django_session    TABLE     �   CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);
 "   DROP TABLE public.django_session;
       public         heap    postgres    false            �            1259    19843    empresa_empresa    TABLE     �  CREATE TABLE public.empresa_empresa (
    id bigint NOT NULL,
    ruc character varying(11) NOT NULL,
    razon_social character varying(200) NOT NULL,
    ciudad character varying(200) NOT NULL,
    direccion character varying(200) NOT NULL,
    telefono character varying(12) NOT NULL,
    imagen character varying(100),
    estado boolean NOT NULL,
    correo character varying(250),
    token_correo character varying(250),
    estado_pago boolean NOT NULL
);
 #   DROP TABLE public.empresa_empresa;
       public         heap    postgres    false            �            1259    19849    empresa_empresa_id_seq    SEQUENCE        CREATE SEQUENCE public.empresa_empresa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.empresa_empresa_id_seq;
       public          postgres    false    220            �           0    0    empresa_empresa_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.empresa_empresa_id_seq OWNED BY public.empresa_empresa.id;
          public          postgres    false    221            �            1259    19851    empresa_sucursal    TABLE     E  CREATE TABLE public.empresa_sucursal (
    id_sucursal integer NOT NULL,
    razon_social character varying(200) NOT NULL,
    ciudad character varying(200) NOT NULL,
    direccion character varying(200) NOT NULL,
    telefono character varying(12) NOT NULL,
    estado boolean NOT NULL,
    id_empresa_id bigint NOT NULL
);
 $   DROP TABLE public.empresa_sucursal;
       public         heap    postgres    false            �            1259    19857     empresa_sucursal_id_sucursal_seq    SEQUENCE     �   CREATE SEQUENCE public.empresa_sucursal_id_sucursal_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.empresa_sucursal_id_sucursal_seq;
       public          postgres    false    222            �           0    0     empresa_sucursal_id_sucursal_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.empresa_sucursal_id_sucursal_seq OWNED BY public.empresa_sucursal.id_sucursal;
          public          postgres    false    223            �            1259    19859    gestion_animal    TABLE     �   CREATE TABLE public.gestion_animal (
    id_animal integer NOT NULL,
    descripcion character varying(50) NOT NULL,
    estado boolean NOT NULL,
    id_empresa_id bigint
);
 "   DROP TABLE public.gestion_animal;
       public         heap    postgres    false            �            1259    19862    gestion_animal_id_animal_seq    SEQUENCE     �   CREATE SEQUENCE public.gestion_animal_id_animal_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.gestion_animal_id_animal_seq;
       public          postgres    false    224            �           0    0    gestion_animal_id_animal_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.gestion_animal_id_animal_seq OWNED BY public.gestion_animal.id_animal;
          public          postgres    false    225            �            1259    19864    gestion_atencion    TABLE     �  CREATE TABLE public.gestion_atencion (
    id_atencion integer NOT NULL,
    monto_total numeric(6,2) NOT NULL,
    entrada timestamp with time zone NOT NULL,
    salida timestamp with time zone NOT NULL,
    estado boolean NOT NULL,
    id_mascota_id integer NOT NULL,
    id_metodo_pago_id integer NOT NULL,
    id_sucursal_id integer NOT NULL,
    usuario_id bigint NOT NULL,
    numero_atencion bigint
);
 $   DROP TABLE public.gestion_atencion;
       public         heap    postgres    false            �            1259    19867    gestion_cliente    TABLE       CREATE TABLE public.gestion_cliente (
    id_cliente integer NOT NULL,
    numero_documento_cliente character varying(11) NOT NULL,
    nombre character varying(50) NOT NULL,
    apellido character varying(50) NOT NULL,
    domicilio character varying(70) NOT NULL,
    celular character varying(9) NOT NULL,
    correo character varying(100) NOT NULL,
    fecha_registro date NOT NULL,
    estado boolean NOT NULL,
    id_tipo_documento_id integer NOT NULL,
    id_sucursal_id integer,
    id_empresa_id bigint
);
 #   DROP TABLE public.gestion_cliente;
       public         heap    postgres    false            �            1259    19870    gestion_cliente_id_cliente_seq    SEQUENCE     �   CREATE SEQUENCE public.gestion_cliente_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.gestion_cliente_id_cliente_seq;
       public          postgres    false    227            �           0    0    gestion_cliente_id_cliente_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.gestion_cliente_id_cliente_seq OWNED BY public.gestion_cliente.id_cliente;
          public          postgres    false    228            �            1259    19872    gestion_detalle_atencion    TABLE     �   CREATE TABLE public.gestion_detalle_atencion (
    id_detalle_atencion integer NOT NULL,
    monto numeric(5,2) NOT NULL,
    comentario text,
    id_atencion_id integer NOT NULL,
    id_servicio_id integer NOT NULL
);
 ,   DROP TABLE public.gestion_detalle_atencion;
       public         heap    postgres    false            �            1259    19878 0   gestion_detalle_atencion_id_detalle_atencion_seq    SEQUENCE     �   CREATE SEQUENCE public.gestion_detalle_atencion_id_detalle_atencion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 G   DROP SEQUENCE public.gestion_detalle_atencion_id_detalle_atencion_seq;
       public          postgres    false    229            �           0    0 0   gestion_detalle_atencion_id_detalle_atencion_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.gestion_detalle_atencion_id_detalle_atencion_seq OWNED BY public.gestion_detalle_atencion.id_detalle_atencion;
          public          postgres    false    230            �            1259    19880    gestion_mascota    TABLE     �  CREATE TABLE public.gestion_mascota (
    id_mascota integer NOT NULL,
    numero_historia integer NOT NULL,
    nombre character varying(50) NOT NULL,
    edad numeric(4,2) NOT NULL,
    sexo integer NOT NULL,
    color character varying(20) NOT NULL,
    peso numeric(4,2) NOT NULL,
    estado boolean NOT NULL,
    id_cliente_id integer NOT NULL,
    id_empresa_id bigint,
    id_raza_id integer NOT NULL,
    id_sucursal_id integer
);
 #   DROP TABLE public.gestion_mascota;
       public         heap    postgres    false            �            1259    19883    gestion_mascota_id_mascota_seq    SEQUENCE     �   CREATE SEQUENCE public.gestion_mascota_id_mascota_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.gestion_mascota_id_mascota_seq;
       public          postgres    false    231            �           0    0    gestion_mascota_id_mascota_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.gestion_mascota_id_mascota_seq OWNED BY public.gestion_mascota.id_mascota;
          public          postgres    false    232            �            1259    19885    gestion_metodopago    TABLE     �   CREATE TABLE public.gestion_metodopago (
    id_metodo_pago integer NOT NULL,
    descripcion character varying(50) NOT NULL,
    estado boolean NOT NULL
);
 &   DROP TABLE public.gestion_metodopago;
       public         heap    postgres    false            �            1259    19888 %   gestion_metodopago_id_metodo_pago_seq    SEQUENCE     �   CREATE SEQUENCE public.gestion_metodopago_id_metodo_pago_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.gestion_metodopago_id_metodo_pago_seq;
       public          postgres    false    233            �           0    0 %   gestion_metodopago_id_metodo_pago_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public.gestion_metodopago_id_metodo_pago_seq OWNED BY public.gestion_metodopago.id_metodo_pago;
          public          postgres    false    234            �            1259    19890    gestion_raza    TABLE     �   CREATE TABLE public.gestion_raza (
    id_raza integer NOT NULL,
    descripcion character varying(50) NOT NULL,
    id_animal_id integer NOT NULL,
    id_empresa_id bigint
);
     DROP TABLE public.gestion_raza;
       public         heap    postgres    false            �            1259    19893    gestion_raza_id_raza_seq    SEQUENCE     �   CREATE SEQUENCE public.gestion_raza_id_raza_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.gestion_raza_id_raza_seq;
       public          postgres    false    235            �           0    0    gestion_raza_id_raza_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.gestion_raza_id_raza_seq OWNED BY public.gestion_raza.id_raza;
          public          postgres    false    236            �            1259    19895    gestion_recordatorio    TABLE     =  CREATE TABLE public.gestion_recordatorio (
    id_recordatorio integer NOT NULL,
    fecha date NOT NULL,
    comentario text,
    estado boolean NOT NULL,
    id_empresa_id bigint,
    id_mascota_id integer NOT NULL,
    id_servicio_id integer NOT NULL,
    usuario_id bigint NOT NULL,
    id_sucursal_id integer
);
 (   DROP TABLE public.gestion_recordatorio;
       public         heap    postgres    false            �            1259    19901 (   gestion_recordatorio_id_recordatorio_seq    SEQUENCE     �   CREATE SEQUENCE public.gestion_recordatorio_id_recordatorio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ?   DROP SEQUENCE public.gestion_recordatorio_id_recordatorio_seq;
       public          postgres    false    237            �           0    0 (   gestion_recordatorio_id_recordatorio_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public.gestion_recordatorio_id_recordatorio_seq OWNED BY public.gestion_recordatorio.id_recordatorio;
          public          postgres    false    238            �            1259    19903    gestion_servicio    TABLE     �   CREATE TABLE public.gestion_servicio (
    id_servicio integer NOT NULL,
    id_animal integer NOT NULL,
    descripcion character varying(50) NOT NULL,
    precio numeric(5,2) NOT NULL,
    estado boolean NOT NULL,
    id_sucursal_id integer
);
 $   DROP TABLE public.gestion_servicio;
       public         heap    postgres    false            �            1259    19906     gestion_servicio_id_servicio_seq    SEQUENCE     �   CREATE SEQUENCE public.gestion_servicio_id_servicio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.gestion_servicio_id_servicio_seq;
       public          postgres    false    239            �           0    0     gestion_servicio_id_servicio_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.gestion_servicio_id_servicio_seq OWNED BY public.gestion_servicio.id_servicio;
          public          postgres    false    240            �            1259    19908    gestion_tipodocumento    TABLE     �   CREATE TABLE public.gestion_tipodocumento (
    id_tipo_documento integer NOT NULL,
    descripcion character varying(50) NOT NULL,
    estado boolean NOT NULL
);
 )   DROP TABLE public.gestion_tipodocumento;
       public         heap    postgres    false            �            1259    19911 +   gestion_tipodocumento_id_tipo_documento_seq    SEQUENCE     �   CREATE SEQUENCE public.gestion_tipodocumento_id_tipo_documento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 B   DROP SEQUENCE public.gestion_tipodocumento_id_tipo_documento_seq;
       public          postgres    false    241            �           0    0 +   gestion_tipodocumento_id_tipo_documento_seq    SEQUENCE OWNED BY     {   ALTER SEQUENCE public.gestion_tipodocumento_id_tipo_documento_seq OWNED BY public.gestion_tipodocumento.id_tipo_documento;
          public          postgres    false    242            �            1259    19913    productos_categoria    TABLE     �   CREATE TABLE public.productos_categoria (
    id_categoria integer NOT NULL,
    descripcion character varying(70) NOT NULL,
    estado boolean NOT NULL,
    id_empresa_id bigint
);
 '   DROP TABLE public.productos_categoria;
       public         heap    postgres    false            �            1259    19916 $   productos_categoria_id_categoria_seq    SEQUENCE     �   CREATE SEQUENCE public.productos_categoria_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ;   DROP SEQUENCE public.productos_categoria_id_categoria_seq;
       public          postgres    false    243            �           0    0 $   productos_categoria_id_categoria_seq    SEQUENCE OWNED BY     m   ALTER SEQUENCE public.productos_categoria_id_categoria_seq OWNED BY public.productos_categoria.id_categoria;
          public          postgres    false    244            �            1259    19918    productos_producto    TABLE       CREATE TABLE public.productos_producto (
    id_producto integer NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text NOT NULL,
    estado boolean NOT NULL,
    id_categoria_id integer NOT NULL,
    id_empresa_id bigint,
    id_unidad_medida_id integer NOT NULL
);
 &   DROP TABLE public.productos_producto;
       public         heap    postgres    false            �            1259    19924 "   productos_producto_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public.productos_producto_id_producto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.productos_producto_id_producto_seq;
       public          postgres    false    245            �           0    0 "   productos_producto_id_producto_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.productos_producto_id_producto_seq OWNED BY public.productos_producto.id_producto;
          public          postgres    false    246            �            1259    19926    productos_productosucursal    TABLE     �  CREATE TABLE public.productos_productosucursal (
    id_producto_sucursal integer NOT NULL,
    precio numeric(5,2) NOT NULL,
    stock integer NOT NULL,
    stock_min integer NOT NULL,
    estado boolean NOT NULL,
    id_producto_id integer NOT NULL,
    id_sucursal_id integer NOT NULL,
    CONSTRAINT productos_productosucursal_stock_check CHECK ((stock >= 0)),
    CONSTRAINT productos_productosucursal_stock_min_check CHECK ((stock_min >= 0))
);
 .   DROP TABLE public.productos_productosucursal;
       public         heap    postgres    false            �            1259    19931 3   productos_productosucursal_id_producto_sucursal_seq    SEQUENCE     �   CREATE SEQUENCE public.productos_productosucursal_id_producto_sucursal_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 J   DROP SEQUENCE public.productos_productosucursal_id_producto_sucursal_seq;
       public          postgres    false    247            �           0    0 3   productos_productosucursal_id_producto_sucursal_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.productos_productosucursal_id_producto_sucursal_seq OWNED BY public.productos_productosucursal.id_producto_sucursal;
          public          postgres    false    248            �            1259    19933    productos_unidadmedida    TABLE     �   CREATE TABLE public.productos_unidadmedida (
    id_unidad_medida integer NOT NULL,
    descripcion character varying(50) NOT NULL,
    estado boolean NOT NULL,
    id_empresa_id bigint
);
 *   DROP TABLE public.productos_unidadmedida;
       public         heap    postgres    false            �            1259    19936 +   productos_unidadmedida_id_unidad_medida_seq    SEQUENCE     �   CREATE SEQUENCE public.productos_unidadmedida_id_unidad_medida_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 B   DROP SEQUENCE public.productos_unidadmedida_id_unidad_medida_seq;
       public          postgres    false    249            �           0    0 +   productos_unidadmedida_id_unidad_medida_seq    SEQUENCE OWNED BY     {   ALTER SEQUENCE public.productos_unidadmedida_id_unidad_medida_seq OWNED BY public.productos_unidadmedida.id_unidad_medida;
          public          postgres    false    250            �            1259    19938    report_definition    TABLE     �   CREATE TABLE public.report_definition (
    id bigint NOT NULL,
    report_definition text NOT NULL,
    report_type character varying(100) NOT NULL,
    remark text,
    last_modified_at timestamp with time zone NOT NULL
);
 %   DROP TABLE public.report_definition;
       public         heap    postgres    false            �            1259    19944    report_definition_id_seq    SEQUENCE     �   CREATE SEQUENCE public.report_definition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.report_definition_id_seq;
       public          postgres    false    251            �           0    0    report_definition_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.report_definition_id_seq OWNED BY public.report_definition.id;
          public          postgres    false    252            �            1259    19946    report_request    TABLE     (  CREATE TABLE public.report_request (
    id bigint NOT NULL,
    key character varying(36) NOT NULL,
    report_definition text NOT NULL,
    data text NOT NULL,
    is_test_data boolean NOT NULL,
    pdf_file bytea,
    pdf_file_size integer,
    created_on timestamp with time zone NOT NULL
);
 "   DROP TABLE public.report_request;
       public         heap    postgres    false            �            1259    19952    report_request_id_seq    SEQUENCE     ~   CREATE SEQUENCE public.report_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.report_request_id_seq;
       public          postgres    false    253            �           0    0    report_request_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.report_request_id_seq OWNED BY public.report_request.id;
          public          postgres    false    254            �            1259    19954    usuarios_usuario    TABLE       CREATE TABLE public.usuarios_usuario (
    id bigint NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    token uuid,
    id_sucursal integer
);
 $   DROP TABLE public.usuarios_usuario;
       public         heap    postgres    false                        1259    19960    usuarios_usuario_groups    TABLE     �   CREATE TABLE public.usuarios_usuario_groups (
    id bigint NOT NULL,
    usuario_id bigint NOT NULL,
    group_id integer NOT NULL
);
 +   DROP TABLE public.usuarios_usuario_groups;
       public         heap    postgres    false                       1259    19963    usuarios_usuario_groups_id_seq    SEQUENCE     �   CREATE SEQUENCE public.usuarios_usuario_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.usuarios_usuario_groups_id_seq;
       public          postgres    false    256            �           0    0    usuarios_usuario_groups_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.usuarios_usuario_groups_id_seq OWNED BY public.usuarios_usuario_groups.id;
          public          postgres    false    257                       1259    19965    usuarios_usuario_id_seq    SEQUENCE     �   CREATE SEQUENCE public.usuarios_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.usuarios_usuario_id_seq;
       public          postgres    false    255            �           0    0    usuarios_usuario_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.usuarios_usuario_id_seq OWNED BY public.usuarios_usuario.id;
          public          postgres    false    258                       1259    19967 !   usuarios_usuario_user_permissions    TABLE     �   CREATE TABLE public.usuarios_usuario_user_permissions (
    id bigint NOT NULL,
    usuario_id bigint NOT NULL,
    permission_id integer NOT NULL
);
 5   DROP TABLE public.usuarios_usuario_user_permissions;
       public         heap    postgres    false                       1259    19970 (   usuarios_usuario_user_permissions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.usuarios_usuario_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ?   DROP SEQUENCE public.usuarios_usuario_user_permissions_id_seq;
       public          postgres    false    259            �           0    0 (   usuarios_usuario_user_permissions_id_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public.usuarios_usuario_user_permissions_id_seq OWNED BY public.usuarios_usuario_user_permissions.id;
          public          postgres    false    260                       1259    19972    ventas_correlativo    TABLE     �  CREATE TABLE public.ventas_correlativo (
    id_correlativo integer NOT NULL,
    serie character varying(4) NOT NULL,
    primer_numero integer NOT NULL,
    ultimo_numero_registrado bigint,
    max_correlativo bigint NOT NULL,
    id_tipo_comprobante_id integer NOT NULL,
    id_empresa_id bigint NOT NULL,
    CONSTRAINT ventas_correlativo_max_correlativo_check CHECK ((max_correlativo >= 0)),
    CONSTRAINT ventas_correlativo_ultimo_numero_registrado_check CHECK ((ultimo_numero_registrado >= 0))
);
 &   DROP TABLE public.ventas_correlativo;
       public         heap    postgres    false                       1259    19977 %   ventas_correlativo_id_correlativo_seq    SEQUENCE     �   CREATE SEQUENCE public.ventas_correlativo_id_correlativo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.ventas_correlativo_id_correlativo_seq;
       public          postgres    false    261            �           0    0 %   ventas_correlativo_id_correlativo_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public.ventas_correlativo_id_correlativo_seq OWNED BY public.ventas_correlativo.id_correlativo;
          public          postgres    false    262                       1259    19979    ventas_detalleventa    TABLE     L  CREATE TABLE public.ventas_detalleventa (
    id_detalle_venta integer NOT NULL,
    precio numeric(5,2) NOT NULL,
    cantidad smallint NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    id_venta_id integer NOT NULL,
    id_producto_id integer NOT NULL,
    CONSTRAINT ventas_detalleventa_cantidad_check CHECK ((cantidad >= 0))
);
 '   DROP TABLE public.ventas_detalleventa;
       public         heap    postgres    false                       1259    19983 (   ventas_detalleventa_id_detalle_venta_seq    SEQUENCE     �   CREATE SEQUENCE public.ventas_detalleventa_id_detalle_venta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ?   DROP SEQUENCE public.ventas_detalleventa_id_detalle_venta_seq;
       public          postgres    false    263            �           0    0 (   ventas_detalleventa_id_detalle_venta_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public.ventas_detalleventa_id_detalle_venta_seq OWNED BY public.ventas_detalleventa.id_detalle_venta;
          public          postgres    false    264            	           1259    19985    ventas_parametro    TABLE     �   CREATE TABLE public.ventas_parametro (
    id_parametro integer NOT NULL,
    nombre character varying(20) NOT NULL,
    valor numeric(6,2) NOT NULL,
    estado boolean NOT NULL
);
 $   DROP TABLE public.ventas_parametro;
       public         heap    postgres    false            
           1259    19988 !   ventas_parametro_id_parametro_seq    SEQUENCE     �   CREATE SEQUENCE public.ventas_parametro_id_parametro_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.ventas_parametro_id_parametro_seq;
       public          postgres    false    265            �           0    0 !   ventas_parametro_id_parametro_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.ventas_parametro_id_parametro_seq OWNED BY public.ventas_parametro.id_parametro;
          public          postgres    false    266                       1259    19990    ventas_tipocomprobante    TABLE     �   CREATE TABLE public.ventas_tipocomprobante (
    id_tipo_comprobante integer NOT NULL,
    descripcion character varying(25) NOT NULL,
    estado boolean NOT NULL,
    id_empresa_id bigint NOT NULL
);
 *   DROP TABLE public.ventas_tipocomprobante;
       public         heap    postgres    false                       1259    19993 .   ventas_tipocomprobante_id_tipo_comprobante_seq    SEQUENCE     �   CREATE SEQUENCE public.ventas_tipocomprobante_id_tipo_comprobante_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 E   DROP SEQUENCE public.ventas_tipocomprobante_id_tipo_comprobante_seq;
       public          postgres    false    267            �           0    0 .   ventas_tipocomprobante_id_tipo_comprobante_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.ventas_tipocomprobante_id_tipo_comprobante_seq OWNED BY public.ventas_tipocomprobante.id_tipo_comprobante;
          public          postgres    false    268                       1259    19995    ventas_venta    TABLE     [  CREATE TABLE public.ventas_venta (
    id_venta integer NOT NULL,
    serie character varying(4) NOT NULL,
    numero integer NOT NULL,
    monto_total numeric(10,2) NOT NULL,
    operacion_gravada numeric(8,2) NOT NULL,
    porcentaje_igv numeric(6,2) NOT NULL,
    igv numeric(7,2) NOT NULL,
    fecha date NOT NULL,
    estado integer NOT NULL,
    motivo_anulacion text,
    id_usuario_anulador integer,
    id_cliente_id integer NOT NULL,
    id_metodo_pago_id integer NOT NULL,
    id_sucursal_id integer NOT NULL,
    id_tipo_comprobante_id integer NOT NULL,
    id_usuario_id bigint NOT NULL
);
     DROP TABLE public.ventas_venta;
       public         heap    postgres    false                       1259    20001    view_listar_correlativo_empresa    VIEW     �  CREATE VIEW public.view_listar_correlativo_empresa AS
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
 2   DROP VIEW public.view_listar_correlativo_empresa;
       public          postgres    false    261    261    261    261    261    267    267    261    261                       1259    20005    view_listar_permisos    VIEW     8  CREATE VIEW public.view_listar_permisos AS
 SELECT ap.codename,
    ap.name
   FROM (public.auth_permission ap
     JOIN public.django_content_type ct ON ((ap.content_type_id = ct.id)))
  WHERE (((ct.app_label)::text !~~ 'auth'::text) AND ((ct.app_label)::text !~~ 'admin'::text) AND ((ct.app_label)::text !~~ 'contenttypes'::text) AND ((ct.app_label)::text !~~ 'sessions'::text) AND ((ct.app_label)::text !~~ 'report'::text) AND ((ct.model)::text !~~ 'metodopago'::text) AND ((ct.model)::text !~~ 'tipodocumento'::text) AND ((ct.model)::text !~~ 'parametro'::text));
 '   DROP VIEW public.view_listar_permisos;
       public          postgres    false    206    206    206    215    215    215                       1259    20009    view_listar_permisos_usuario    VIEW     �   CREATE VIEW public.view_listar_permisos_usuario AS
 SELECT ap.codename,
    usp.usuario_id
   FROM (public.usuarios_usuario_user_permissions usp
     JOIN public.auth_permission ap ON ((usp.permission_id = ap.id)));
 /   DROP VIEW public.view_listar_permisos_usuario;
       public          postgres    false    206    206    259    259                       1259    20013 !   vw_exportar_reporte_lista_mascota    VIEW       CREATE VIEW public.vw_exportar_reporte_lista_mascota AS
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
 4   DROP VIEW public.vw_exportar_reporte_lista_mascota;
       public          postgres    false    222    235    235    235    231    231    231    231    231    231    231    231    231    227    227    227    224    224                       1259    20018    vw_exportar_reporte_producto    VIEW       CREATE VIEW public.vw_exportar_reporte_producto AS
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
 /   DROP VIEW public.vw_exportar_reporte_producto;
       public          postgres    false    243    245    245    245    249    249    245    243    245                       1259    20023    vw_exportar_reporte_servicio    VIEW     �  CREATE VIEW public.vw_exportar_reporte_servicio AS
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
 /   DROP VIEW public.vw_exportar_reporte_servicio;
       public          postgres    false    239    239    239    224    224    239    239                       1259    20027    vw_listar_mascota    VIEW     �  CREATE VIEW public.vw_listar_mascota AS
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
 $   DROP VIEW public.vw_listar_mascota;
       public          postgres    false    231    220    224    224    227    227    231    231    231    231    231    231    231    231    231    231    235    235    235                       1259    20032    vw_listar_producto    VIEW     �  CREATE VIEW public.vw_listar_producto AS
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
 %   DROP VIEW public.vw_listar_producto;
       public          postgres    false    245    243    243    245    245    245    249    249    245    245                       1259    20036    vw_listar_proveedor    VIEW     �  CREATE VIEW public.vw_listar_proveedor AS
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
 &   DROP VIEW public.vw_listar_proveedor;
       public          postgres    false    211    241    241    211    211    211    211    211    211    211    211                       1259    20040    vw_listar_raza    VIEW     :  CREATE VIEW public.vw_listar_raza AS
 SELECT gr.id_raza,
    ga.id_animal AS codigo_animal,
    ga.descripcion AS animal,
    gr.descripcion AS raza,
    gr.id_empresa_id AS id_empresa
   FROM (public.gestion_raza gr
     JOIN public.gestion_animal ga ON ((gr.id_animal_id = ga.id_animal)))
  ORDER BY gr.id_raza;
 !   DROP VIEW public.vw_listar_raza;
       public          postgres    false    235    235    235    235    224    224                       1259    20044    vw_listar_recordatorio    VIEW       CREATE VIEW public.vw_listar_recordatorio AS
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
 )   DROP VIEW public.vw_listar_recordatorio;
       public          postgres    false    239    237    237    237    237    237    231    239    231    231    237    237    237                       1259    20049    vw_listar_servicio    VIEW     /  CREATE VIEW public.vw_listar_servicio AS
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
 %   DROP VIEW public.vw_listar_servicio;
       public          postgres    false    239    239    239    224    239    239    224    239                       2604    20053    auth_group id    DEFAULT     n   ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);
 <   ALTER TABLE public.auth_group ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    203    202                       2604    20054    auth_group_permissions id    DEFAULT     �   ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);
 H   ALTER TABLE public.auth_group_permissions ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    205    204                       2604    20055    auth_permission id    DEFAULT     x   ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);
 A   ALTER TABLE public.auth_permission ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    207    206                       2604    20056 '   compras_detallecompra id_detalle_compra    DEFAULT     �   ALTER TABLE ONLY public.compras_detallecompra ALTER COLUMN id_detalle_compra SET DEFAULT nextval('public.compras_detallecompra_id_detalle_compra_seq'::regclass);
 V   ALTER TABLE public.compras_detallecompra ALTER COLUMN id_detalle_compra DROP DEFAULT;
       public          postgres    false    210    209                       2604    20057    compras_proveedor id_proveedor    DEFAULT     �   ALTER TABLE ONLY public.compras_proveedor ALTER COLUMN id_proveedor SET DEFAULT nextval('public.compras_proveedor_id_proveedor_seq'::regclass);
 M   ALTER TABLE public.compras_proveedor ALTER COLUMN id_proveedor DROP DEFAULT;
       public          postgres    false    212    211                       2604    20058    django_admin_log id    DEFAULT     z   ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);
 B   ALTER TABLE public.django_admin_log ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    214    213                       2604    20059    django_content_type id    DEFAULT     �   ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);
 E   ALTER TABLE public.django_content_type ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    215                       2604    20060    django_migrations id    DEFAULT     |   ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);
 C   ALTER TABLE public.django_migrations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217                       2604    20061    empresa_empresa id    DEFAULT     x   ALTER TABLE ONLY public.empresa_empresa ALTER COLUMN id SET DEFAULT nextval('public.empresa_empresa_id_seq'::regclass);
 A   ALTER TABLE public.empresa_empresa ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    221    220                       2604    20062    empresa_sucursal id_sucursal    DEFAULT     �   ALTER TABLE ONLY public.empresa_sucursal ALTER COLUMN id_sucursal SET DEFAULT nextval('public.empresa_sucursal_id_sucursal_seq'::regclass);
 K   ALTER TABLE public.empresa_sucursal ALTER COLUMN id_sucursal DROP DEFAULT;
       public          postgres    false    223    222                       2604    20063    gestion_animal id_animal    DEFAULT     �   ALTER TABLE ONLY public.gestion_animal ALTER COLUMN id_animal SET DEFAULT nextval('public.gestion_animal_id_animal_seq'::regclass);
 G   ALTER TABLE public.gestion_animal ALTER COLUMN id_animal DROP DEFAULT;
       public          postgres    false    225    224                       2604    20064    gestion_cliente id_cliente    DEFAULT     �   ALTER TABLE ONLY public.gestion_cliente ALTER COLUMN id_cliente SET DEFAULT nextval('public.gestion_cliente_id_cliente_seq'::regclass);
 I   ALTER TABLE public.gestion_cliente ALTER COLUMN id_cliente DROP DEFAULT;
       public          postgres    false    228    227                       2604    20065 ,   gestion_detalle_atencion id_detalle_atencion    DEFAULT     �   ALTER TABLE ONLY public.gestion_detalle_atencion ALTER COLUMN id_detalle_atencion SET DEFAULT nextval('public.gestion_detalle_atencion_id_detalle_atencion_seq'::regclass);
 [   ALTER TABLE public.gestion_detalle_atencion ALTER COLUMN id_detalle_atencion DROP DEFAULT;
       public          postgres    false    230    229                        2604    20066    gestion_mascota id_mascota    DEFAULT     �   ALTER TABLE ONLY public.gestion_mascota ALTER COLUMN id_mascota SET DEFAULT nextval('public.gestion_mascota_id_mascota_seq'::regclass);
 I   ALTER TABLE public.gestion_mascota ALTER COLUMN id_mascota DROP DEFAULT;
       public          postgres    false    232    231            !           2604    20067 !   gestion_metodopago id_metodo_pago    DEFAULT     �   ALTER TABLE ONLY public.gestion_metodopago ALTER COLUMN id_metodo_pago SET DEFAULT nextval('public.gestion_metodopago_id_metodo_pago_seq'::regclass);
 P   ALTER TABLE public.gestion_metodopago ALTER COLUMN id_metodo_pago DROP DEFAULT;
       public          postgres    false    234    233            "           2604    20068    gestion_raza id_raza    DEFAULT     |   ALTER TABLE ONLY public.gestion_raza ALTER COLUMN id_raza SET DEFAULT nextval('public.gestion_raza_id_raza_seq'::regclass);
 C   ALTER TABLE public.gestion_raza ALTER COLUMN id_raza DROP DEFAULT;
       public          postgres    false    236    235            #           2604    20069 $   gestion_recordatorio id_recordatorio    DEFAULT     �   ALTER TABLE ONLY public.gestion_recordatorio ALTER COLUMN id_recordatorio SET DEFAULT nextval('public.gestion_recordatorio_id_recordatorio_seq'::regclass);
 S   ALTER TABLE public.gestion_recordatorio ALTER COLUMN id_recordatorio DROP DEFAULT;
       public          postgres    false    238    237            $           2604    20070    gestion_servicio id_servicio    DEFAULT     �   ALTER TABLE ONLY public.gestion_servicio ALTER COLUMN id_servicio SET DEFAULT nextval('public.gestion_servicio_id_servicio_seq'::regclass);
 K   ALTER TABLE public.gestion_servicio ALTER COLUMN id_servicio DROP DEFAULT;
       public          postgres    false    240    239            %           2604    20071 '   gestion_tipodocumento id_tipo_documento    DEFAULT     �   ALTER TABLE ONLY public.gestion_tipodocumento ALTER COLUMN id_tipo_documento SET DEFAULT nextval('public.gestion_tipodocumento_id_tipo_documento_seq'::regclass);
 V   ALTER TABLE public.gestion_tipodocumento ALTER COLUMN id_tipo_documento DROP DEFAULT;
       public          postgres    false    242    241            &           2604    20072     productos_categoria id_categoria    DEFAULT     �   ALTER TABLE ONLY public.productos_categoria ALTER COLUMN id_categoria SET DEFAULT nextval('public.productos_categoria_id_categoria_seq'::regclass);
 O   ALTER TABLE public.productos_categoria ALTER COLUMN id_categoria DROP DEFAULT;
       public          postgres    false    244    243            '           2604    20073    productos_producto id_producto    DEFAULT     �   ALTER TABLE ONLY public.productos_producto ALTER COLUMN id_producto SET DEFAULT nextval('public.productos_producto_id_producto_seq'::regclass);
 M   ALTER TABLE public.productos_producto ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    246    245            (           2604    20074 /   productos_productosucursal id_producto_sucursal    DEFAULT     �   ALTER TABLE ONLY public.productos_productosucursal ALTER COLUMN id_producto_sucursal SET DEFAULT nextval('public.productos_productosucursal_id_producto_sucursal_seq'::regclass);
 ^   ALTER TABLE public.productos_productosucursal ALTER COLUMN id_producto_sucursal DROP DEFAULT;
       public          postgres    false    248    247            +           2604    20075 '   productos_unidadmedida id_unidad_medida    DEFAULT     �   ALTER TABLE ONLY public.productos_unidadmedida ALTER COLUMN id_unidad_medida SET DEFAULT nextval('public.productos_unidadmedida_id_unidad_medida_seq'::regclass);
 V   ALTER TABLE public.productos_unidadmedida ALTER COLUMN id_unidad_medida DROP DEFAULT;
       public          postgres    false    250    249            ,           2604    20076    report_definition id    DEFAULT     |   ALTER TABLE ONLY public.report_definition ALTER COLUMN id SET DEFAULT nextval('public.report_definition_id_seq'::regclass);
 C   ALTER TABLE public.report_definition ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    252    251            -           2604    20077    report_request id    DEFAULT     v   ALTER TABLE ONLY public.report_request ALTER COLUMN id SET DEFAULT nextval('public.report_request_id_seq'::regclass);
 @   ALTER TABLE public.report_request ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    254    253            .           2604    20078    usuarios_usuario id    DEFAULT     z   ALTER TABLE ONLY public.usuarios_usuario ALTER COLUMN id SET DEFAULT nextval('public.usuarios_usuario_id_seq'::regclass);
 B   ALTER TABLE public.usuarios_usuario ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    258    255            /           2604    20079    usuarios_usuario_groups id    DEFAULT     �   ALTER TABLE ONLY public.usuarios_usuario_groups ALTER COLUMN id SET DEFAULT nextval('public.usuarios_usuario_groups_id_seq'::regclass);
 I   ALTER TABLE public.usuarios_usuario_groups ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    257    256            0           2604    20080 $   usuarios_usuario_user_permissions id    DEFAULT     �   ALTER TABLE ONLY public.usuarios_usuario_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.usuarios_usuario_user_permissions_id_seq'::regclass);
 S   ALTER TABLE public.usuarios_usuario_user_permissions ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    260    259            1           2604    20081 !   ventas_correlativo id_correlativo    DEFAULT     �   ALTER TABLE ONLY public.ventas_correlativo ALTER COLUMN id_correlativo SET DEFAULT nextval('public.ventas_correlativo_id_correlativo_seq'::regclass);
 P   ALTER TABLE public.ventas_correlativo ALTER COLUMN id_correlativo DROP DEFAULT;
       public          postgres    false    262    261            4           2604    20082 $   ventas_detalleventa id_detalle_venta    DEFAULT     �   ALTER TABLE ONLY public.ventas_detalleventa ALTER COLUMN id_detalle_venta SET DEFAULT nextval('public.ventas_detalleventa_id_detalle_venta_seq'::regclass);
 S   ALTER TABLE public.ventas_detalleventa ALTER COLUMN id_detalle_venta DROP DEFAULT;
       public          postgres    false    264    263            6           2604    20083    ventas_parametro id_parametro    DEFAULT     �   ALTER TABLE ONLY public.ventas_parametro ALTER COLUMN id_parametro SET DEFAULT nextval('public.ventas_parametro_id_parametro_seq'::regclass);
 L   ALTER TABLE public.ventas_parametro ALTER COLUMN id_parametro DROP DEFAULT;
       public          postgres    false    266    265            7           2604    20084 *   ventas_tipocomprobante id_tipo_comprobante    DEFAULT     �   ALTER TABLE ONLY public.ventas_tipocomprobante ALTER COLUMN id_tipo_comprobante SET DEFAULT nextval('public.ventas_tipocomprobante_id_tipo_comprobante_seq'::regclass);
 Y   ALTER TABLE public.ventas_tipocomprobante ALTER COLUMN id_tipo_comprobante DROP DEFAULT;
       public          postgres    false    268    267            �          0    19786 
   auth_group 
   TABLE DATA           .   COPY public.auth_group (id, name) FROM stdin;
    public          postgres    false    202   b�      �          0    19791    auth_group_permissions 
   TABLE DATA           M   COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
    public          postgres    false    204   ��      �          0    19796    auth_permission 
   TABLE DATA           N   COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
    public          postgres    false    206   ˺      �          0    19801    compras_compra 
   TABLE DATA           �   COPY public.compras_compra (id_compra, serie, numero, impuesto, monto_total, fecha, estado, id_proveedor_id, id_sucursal_id, id_tipo_comprobante_id, id_usuario_id, fecha_registro) FROM stdin;
    public          postgres    false    208   �      �          0    19804    compras_detallecompra 
   TABLE DATA           |   COPY public.compras_detallecompra (id_detalle_compra, precio, cantidad, subtotal, id_compra_id, id_producto_id) FROM stdin;
    public          postgres    false    209   k�      �          0    19810    compras_proveedor 
   TABLE DATA           �   COPY public.compras_proveedor (id_proveedor, numero_documento_proveedor, razon_social, telefono_proveedor, telefono_contacto, direccion, estado, id_tipo_documento_id, id_empresa_id) FROM stdin;
    public          postgres    false    211   ��      �          0    19815    django_admin_log 
   TABLE DATA           �   COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
    public          postgres    false    213   F�      �          0    19824    django_content_type 
   TABLE DATA           C   COPY public.django_content_type (id, app_label, model) FROM stdin;
    public          postgres    false    215   �      �          0    19829    django_migrations 
   TABLE DATA           C   COPY public.django_migrations (id, app, name, applied) FROM stdin;
    public          postgres    false    217   f�      �          0    19837    django_session 
   TABLE DATA           P   COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
    public          postgres    false    219   /�      �          0    19843    empresa_empresa 
   TABLE DATA           �   COPY public.empresa_empresa (id, ruc, razon_social, ciudad, direccion, telefono, imagen, estado, correo, token_correo, estado_pago) FROM stdin;
    public          postgres    false    220   )�      �          0    19851    empresa_sucursal 
   TABLE DATA           y   COPY public.empresa_sucursal (id_sucursal, razon_social, ciudad, direccion, telefono, estado, id_empresa_id) FROM stdin;
    public          postgres    false    222   %�      �          0    19859    gestion_animal 
   TABLE DATA           W   COPY public.gestion_animal (id_animal, descripcion, estado, id_empresa_id) FROM stdin;
    public          postgres    false    224   �      �          0    19864    gestion_atencion 
   TABLE DATA           �   COPY public.gestion_atencion (id_atencion, monto_total, entrada, salida, estado, id_mascota_id, id_metodo_pago_id, id_sucursal_id, usuario_id, numero_atencion) FROM stdin;
    public          postgres    false    226   [�      �          0    19867    gestion_cliente 
   TABLE DATA           �   COPY public.gestion_cliente (id_cliente, numero_documento_cliente, nombre, apellido, domicilio, celular, correo, fecha_registro, estado, id_tipo_documento_id, id_sucursal_id, id_empresa_id) FROM stdin;
    public          postgres    false    227   I�      �          0    19872    gestion_detalle_atencion 
   TABLE DATA           z   COPY public.gestion_detalle_atencion (id_detalle_atencion, monto, comentario, id_atencion_id, id_servicio_id) FROM stdin;
    public          postgres    false    229   (�      �          0    19880    gestion_mascota 
   TABLE DATA           �   COPY public.gestion_mascota (id_mascota, numero_historia, nombre, edad, sexo, color, peso, estado, id_cliente_id, id_empresa_id, id_raza_id, id_sucursal_id) FROM stdin;
    public          postgres    false    231   v�      �          0    19885    gestion_metodopago 
   TABLE DATA           Q   COPY public.gestion_metodopago (id_metodo_pago, descripcion, estado) FROM stdin;
    public          postgres    false    233    �      �          0    19890    gestion_raza 
   TABLE DATA           Y   COPY public.gestion_raza (id_raza, descripcion, id_animal_id, id_empresa_id) FROM stdin;
    public          postgres    false    235   d�      �          0    19895    gestion_recordatorio 
   TABLE DATA           �   COPY public.gestion_recordatorio (id_recordatorio, fecha, comentario, estado, id_empresa_id, id_mascota_id, id_servicio_id, usuario_id, id_sucursal_id) FROM stdin;
    public          postgres    false    237   ��      �          0    19903    gestion_servicio 
   TABLE DATA           o   COPY public.gestion_servicio (id_servicio, id_animal, descripcion, precio, estado, id_sucursal_id) FROM stdin;
    public          postgres    false    239   ��      �          0    19908    gestion_tipodocumento 
   TABLE DATA           W   COPY public.gestion_tipodocumento (id_tipo_documento, descripcion, estado) FROM stdin;
    public          postgres    false    241   c�      �          0    19913    productos_categoria 
   TABLE DATA           _   COPY public.productos_categoria (id_categoria, descripcion, estado, id_empresa_id) FROM stdin;
    public          postgres    false    243   ��      �          0    19918    productos_producto 
   TABLE DATA           �   COPY public.productos_producto (id_producto, nombre, descripcion, estado, id_categoria_id, id_empresa_id, id_unidad_medida_id) FROM stdin;
    public          postgres    false    245   ��      �          0    19926    productos_productosucursal 
   TABLE DATA           �   COPY public.productos_productosucursal (id_producto_sucursal, precio, stock, stock_min, estado, id_producto_id, id_sucursal_id) FROM stdin;
    public          postgres    false    247   ��      �          0    19933    productos_unidadmedida 
   TABLE DATA           f   COPY public.productos_unidadmedida (id_unidad_medida, descripcion, estado, id_empresa_id) FROM stdin;
    public          postgres    false    249   D�      �          0    19938    report_definition 
   TABLE DATA           i   COPY public.report_definition (id, report_definition, report_type, remark, last_modified_at) FROM stdin;
    public          postgres    false    251   ��      �          0    19946    report_request 
   TABLE DATA           }   COPY public.report_request (id, key, report_definition, data, is_test_data, pdf_file, pdf_file_size, created_on) FROM stdin;
    public          postgres    false    253   D*      �          0    19954    usuarios_usuario 
   TABLE DATA           �   COPY public.usuarios_usuario (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined, token, id_sucursal) FROM stdin;
    public          postgres    false    255   ,M      �          0    19960    usuarios_usuario_groups 
   TABLE DATA           K   COPY public.usuarios_usuario_groups (id, usuario_id, group_id) FROM stdin;
    public          postgres    false    256   wP      �          0    19967 !   usuarios_usuario_user_permissions 
   TABLE DATA           Z   COPY public.usuarios_usuario_user_permissions (id, usuario_id, permission_id) FROM stdin;
    public          postgres    false    259   �P      �          0    19972    ventas_correlativo 
   TABLE DATA           �   COPY public.ventas_correlativo (id_correlativo, serie, primer_numero, ultimo_numero_registrado, max_correlativo, id_tipo_comprobante_id, id_empresa_id) FROM stdin;
    public          postgres    false    261   V      �          0    19979    ventas_detalleventa 
   TABLE DATA           x   COPY public.ventas_detalleventa (id_detalle_venta, precio, cantidad, subtotal, id_venta_id, id_producto_id) FROM stdin;
    public          postgres    false    263   iV      �          0    19985    ventas_parametro 
   TABLE DATA           O   COPY public.ventas_parametro (id_parametro, nombre, valor, estado) FROM stdin;
    public          postgres    false    265   �b      �          0    19990    ventas_tipocomprobante 
   TABLE DATA           i   COPY public.ventas_tipocomprobante (id_tipo_comprobante, descripcion, estado, id_empresa_id) FROM stdin;
    public          postgres    false    267   �b      �          0    19995    ventas_venta 
   TABLE DATA             COPY public.ventas_venta (id_venta, serie, numero, monto_total, operacion_gravada, porcentaje_igv, igv, fecha, estado, motivo_anulacion, id_usuario_anulador, id_cliente_id, id_metodo_pago_id, id_sucursal_id, id_tipo_comprobante_id, id_usuario_id) FROM stdin;
    public          postgres    false    269   $c      �           0    0    auth_group_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.auth_group_id_seq', 1, true);
          public          postgres    false    203            �           0    0    auth_group_permissions_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 88, true);
          public          postgres    false    205                        0    0    auth_permission_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.auth_permission_id_seq', 129, true);
          public          postgres    false    207                       0    0 +   compras_detallecompra_id_detalle_compra_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('public.compras_detallecompra_id_detalle_compra_seq', 38, true);
          public          postgres    false    210                       0    0 "   compras_proveedor_id_proveedor_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.compras_proveedor_id_proveedor_seq', 2, true);
          public          postgres    false    212                       0    0    django_admin_log_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.django_admin_log_id_seq', 122, true);
          public          postgres    false    214                       0    0    django_content_type_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.django_content_type_id_seq', 32, true);
          public          postgres    false    216                       0    0    django_migrations_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.django_migrations_id_seq', 43, true);
          public          postgres    false    218                       0    0    empresa_empresa_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.empresa_empresa_id_seq', 3, true);
          public          postgres    false    221                       0    0     empresa_sucursal_id_sucursal_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.empresa_sucursal_id_sucursal_seq', 5, true);
          public          postgres    false    223                       0    0    gestion_animal_id_animal_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.gestion_animal_id_animal_seq', 4, true);
          public          postgres    false    225            	           0    0    gestion_cliente_id_cliente_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.gestion_cliente_id_cliente_seq', 5, true);
          public          postgres    false    228            
           0    0 0   gestion_detalle_atencion_id_detalle_atencion_seq    SEQUENCE SET     ^   SELECT pg_catalog.setval('public.gestion_detalle_atencion_id_detalle_atencion_seq', 7, true);
          public          postgres    false    230                       0    0    gestion_mascota_id_mascota_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.gestion_mascota_id_mascota_seq', 8, true);
          public          postgres    false    232                       0    0 %   gestion_metodopago_id_metodo_pago_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.gestion_metodopago_id_metodo_pago_seq', 4, true);
          public          postgres    false    234                       0    0    gestion_raza_id_raza_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.gestion_raza_id_raza_seq', 8, true);
          public          postgres    false    236                       0    0 (   gestion_recordatorio_id_recordatorio_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('public.gestion_recordatorio_id_recordatorio_seq', 3, true);
          public          postgres    false    238                       0    0     gestion_servicio_id_servicio_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.gestion_servicio_id_servicio_seq', 8, true);
          public          postgres    false    240                       0    0 +   gestion_tipodocumento_id_tipo_documento_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public.gestion_tipodocumento_id_tipo_documento_seq', 2, true);
          public          postgres    false    242                       0    0 $   productos_categoria_id_categoria_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.productos_categoria_id_categoria_seq', 29, true);
          public          postgres    false    244                       0    0 "   productos_producto_id_producto_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.productos_producto_id_producto_seq', 161, true);
          public          postgres    false    246                       0    0 3   productos_productosucursal_id_producto_sucursal_seq    SEQUENCE SET     c   SELECT pg_catalog.setval('public.productos_productosucursal_id_producto_sucursal_seq', 158, true);
          public          postgres    false    248                       0    0 +   productos_unidadmedida_id_unidad_medida_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public.productos_unidadmedida_id_unidad_medida_seq', 5, true);
          public          postgres    false    250                       0    0    report_definition_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.report_definition_id_seq', 10, true);
          public          postgres    false    252                       0    0    report_request_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.report_request_id_seq', 2, true);
          public          postgres    false    254                       0    0    usuarios_usuario_groups_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.usuarios_usuario_groups_id_seq', 4, true);
          public          postgres    false    257                       0    0    usuarios_usuario_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.usuarios_usuario_id_seq', 9, true);
          public          postgres    false    258                       0    0 (   usuarios_usuario_user_permissions_id_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('public.usuarios_usuario_user_permissions_id_seq', 1214, true);
          public          postgres    false    260                       0    0 %   ventas_correlativo_id_correlativo_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.ventas_correlativo_id_correlativo_seq', 7, true);
          public          postgres    false    262                       0    0 (   ventas_detalleventa_id_detalle_venta_seq    SEQUENCE SET     X   SELECT pg_catalog.setval('public.ventas_detalleventa_id_detalle_venta_seq', 555, true);
          public          postgres    false    264                       0    0 !   ventas_parametro_id_parametro_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.ventas_parametro_id_parametro_seq', 1, true);
          public          postgres    false    266                       0    0 .   ventas_tipocomprobante_id_tipo_comprobante_seq    SEQUENCE SET     \   SELECT pg_catalog.setval('public.ventas_tipocomprobante_id_tipo_comprobante_seq', 9, true);
          public          postgres    false    268            :           2606    20096    auth_group auth_group_name_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);
 H   ALTER TABLE ONLY public.auth_group DROP CONSTRAINT auth_group_name_key;
       public            postgres    false    202            ?           2606    20098 R   auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);
 |   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq;
       public            postgres    false    204    204            B           2606    20100 2   auth_group_permissions auth_group_permissions_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_pkey;
       public            postgres    false    204            <           2606    20102    auth_group auth_group_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.auth_group DROP CONSTRAINT auth_group_pkey;
       public            postgres    false    202            E           2606    20104 F   auth_permission auth_permission_content_type_id_codename_01ab375a_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);
 p   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq;
       public            postgres    false    206    206            G           2606    20106 $   auth_permission auth_permission_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_pkey;
       public            postgres    false    206            M           2606    20108 "   compras_compra compras_compra_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.compras_compra
    ADD CONSTRAINT compras_compra_pkey PRIMARY KEY (id_compra);
 L   ALTER TABLE ONLY public.compras_compra DROP CONSTRAINT compras_compra_pkey;
       public            postgres    false    208            Q           2606    20110 0   compras_detallecompra compras_detallecompra_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY public.compras_detallecompra
    ADD CONSTRAINT compras_detallecompra_pkey PRIMARY KEY (id_detalle_compra);
 Z   ALTER TABLE ONLY public.compras_detallecompra DROP CONSTRAINT compras_detallecompra_pkey;
       public            postgres    false    209            U           2606    20112 (   compras_proveedor compras_proveedor_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.compras_proveedor
    ADD CONSTRAINT compras_proveedor_pkey PRIMARY KEY (id_proveedor);
 R   ALTER TABLE ONLY public.compras_proveedor DROP CONSTRAINT compras_proveedor_pkey;
       public            postgres    false    211            X           2606    20114 &   django_admin_log django_admin_log_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_pkey;
       public            postgres    false    213            [           2606    20116 E   django_content_type django_content_type_app_label_model_76bd3d3b_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);
 o   ALTER TABLE ONLY public.django_content_type DROP CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq;
       public            postgres    false    215    215            ]           2606    20118 ,   django_content_type django_content_type_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.django_content_type DROP CONSTRAINT django_content_type_pkey;
       public            postgres    false    215            _           2606    20120 (   django_migrations django_migrations_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.django_migrations DROP CONSTRAINT django_migrations_pkey;
       public            postgres    false    217            b           2606    20122 "   django_session django_session_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);
 L   ALTER TABLE ONLY public.django_session DROP CONSTRAINT django_session_pkey;
       public            postgres    false    219            e           2606    20124 $   empresa_empresa empresa_empresa_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.empresa_empresa
    ADD CONSTRAINT empresa_empresa_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.empresa_empresa DROP CONSTRAINT empresa_empresa_pkey;
       public            postgres    false    220            h           2606    20126 &   empresa_sucursal empresa_sucursal_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.empresa_sucursal
    ADD CONSTRAINT empresa_sucursal_pkey PRIMARY KEY (id_sucursal);
 P   ALTER TABLE ONLY public.empresa_sucursal DROP CONSTRAINT empresa_sucursal_pkey;
       public            postgres    false    222            k           2606    20128 "   gestion_animal gestion_animal_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.gestion_animal
    ADD CONSTRAINT gestion_animal_pkey PRIMARY KEY (id_animal);
 L   ALTER TABLE ONLY public.gestion_animal DROP CONSTRAINT gestion_animal_pkey;
       public            postgres    false    224            p           2606    20130 &   gestion_atencion gestion_atencion_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.gestion_atencion
    ADD CONSTRAINT gestion_atencion_pkey PRIMARY KEY (id_atencion);
 P   ALTER TABLE ONLY public.gestion_atencion DROP CONSTRAINT gestion_atencion_pkey;
       public            postgres    false    226            v           2606    20132 $   gestion_cliente gestion_cliente_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.gestion_cliente
    ADD CONSTRAINT gestion_cliente_pkey PRIMARY KEY (id_cliente);
 N   ALTER TABLE ONLY public.gestion_cliente DROP CONSTRAINT gestion_cliente_pkey;
       public            postgres    false    227            z           2606    20134 6   gestion_detalle_atencion gestion_detalle_atencion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.gestion_detalle_atencion
    ADD CONSTRAINT gestion_detalle_atencion_pkey PRIMARY KEY (id_detalle_atencion);
 `   ALTER TABLE ONLY public.gestion_detalle_atencion DROP CONSTRAINT gestion_detalle_atencion_pkey;
       public            postgres    false    229            �           2606    20136 $   gestion_mascota gestion_mascota_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.gestion_mascota
    ADD CONSTRAINT gestion_mascota_pkey PRIMARY KEY (id_mascota);
 N   ALTER TABLE ONLY public.gestion_mascota DROP CONSTRAINT gestion_mascota_pkey;
       public            postgres    false    231            �           2606    20138 *   gestion_metodopago gestion_metodopago_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.gestion_metodopago
    ADD CONSTRAINT gestion_metodopago_pkey PRIMARY KEY (id_metodo_pago);
 T   ALTER TABLE ONLY public.gestion_metodopago DROP CONSTRAINT gestion_metodopago_pkey;
       public            postgres    false    233            �           2606    20140    gestion_raza gestion_raza_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.gestion_raza
    ADD CONSTRAINT gestion_raza_pkey PRIMARY KEY (id_raza);
 H   ALTER TABLE ONLY public.gestion_raza DROP CONSTRAINT gestion_raza_pkey;
       public            postgres    false    235            �           2606    20142 .   gestion_recordatorio gestion_recordatorio_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY public.gestion_recordatorio
    ADD CONSTRAINT gestion_recordatorio_pkey PRIMARY KEY (id_recordatorio);
 X   ALTER TABLE ONLY public.gestion_recordatorio DROP CONSTRAINT gestion_recordatorio_pkey;
       public            postgres    false    237            �           2606    20144 &   gestion_servicio gestion_servicio_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.gestion_servicio
    ADD CONSTRAINT gestion_servicio_pkey PRIMARY KEY (id_servicio);
 P   ALTER TABLE ONLY public.gestion_servicio DROP CONSTRAINT gestion_servicio_pkey;
       public            postgres    false    239            �           2606    20146 0   gestion_tipodocumento gestion_tipodocumento_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY public.gestion_tipodocumento
    ADD CONSTRAINT gestion_tipodocumento_pkey PRIMARY KEY (id_tipo_documento);
 Z   ALTER TABLE ONLY public.gestion_tipodocumento DROP CONSTRAINT gestion_tipodocumento_pkey;
       public            postgres    false    241            �           2606    20148 ,   productos_categoria productos_categoria_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.productos_categoria
    ADD CONSTRAINT productos_categoria_pkey PRIMARY KEY (id_categoria);
 V   ALTER TABLE ONLY public.productos_categoria DROP CONSTRAINT productos_categoria_pkey;
       public            postgres    false    243            �           2606    20150 *   productos_producto productos_producto_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.productos_producto
    ADD CONSTRAINT productos_producto_pkey PRIMARY KEY (id_producto);
 T   ALTER TABLE ONLY public.productos_producto DROP CONSTRAINT productos_producto_pkey;
       public            postgres    false    245            �           2606    20152 :   productos_productosucursal productos_productosucursal_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.productos_productosucursal
    ADD CONSTRAINT productos_productosucursal_pkey PRIMARY KEY (id_producto_sucursal);
 d   ALTER TABLE ONLY public.productos_productosucursal DROP CONSTRAINT productos_productosucursal_pkey;
       public            postgres    false    247            �           2606    20154 =   productos_unidadmedida productos_unidadmedida_descripcion_key 
   CONSTRAINT        ALTER TABLE ONLY public.productos_unidadmedida
    ADD CONSTRAINT productos_unidadmedida_descripcion_key UNIQUE (descripcion);
 g   ALTER TABLE ONLY public.productos_unidadmedida DROP CONSTRAINT productos_unidadmedida_descripcion_key;
       public            postgres    false    249            �           2606    20156 2   productos_unidadmedida productos_unidadmedida_pkey 
   CONSTRAINT     ~   ALTER TABLE ONLY public.productos_unidadmedida
    ADD CONSTRAINT productos_unidadmedida_pkey PRIMARY KEY (id_unidad_medida);
 \   ALTER TABLE ONLY public.productos_unidadmedida DROP CONSTRAINT productos_unidadmedida_pkey;
       public            postgres    false    249            �           2606    20158 (   report_definition report_definition_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.report_definition
    ADD CONSTRAINT report_definition_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.report_definition DROP CONSTRAINT report_definition_pkey;
       public            postgres    false    251            �           2606    20160 3   report_definition report_definition_report_type_key 
   CONSTRAINT     u   ALTER TABLE ONLY public.report_definition
    ADD CONSTRAINT report_definition_report_type_key UNIQUE (report_type);
 ]   ALTER TABLE ONLY public.report_definition DROP CONSTRAINT report_definition_report_type_key;
       public            postgres    false    251            �           2606    20162 "   report_request report_request_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.report_request
    ADD CONSTRAINT report_request_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.report_request DROP CONSTRAINT report_request_pkey;
       public            postgres    false    253            �           2606    20164 4   usuarios_usuario_groups usuarios_usuario_groups_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.usuarios_usuario_groups
    ADD CONSTRAINT usuarios_usuario_groups_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.usuarios_usuario_groups DROP CONSTRAINT usuarios_usuario_groups_pkey;
       public            postgres    false    256            �           2606    20166 Q   usuarios_usuario_groups usuarios_usuario_groups_usuario_id_group_id_4ed5b09e_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.usuarios_usuario_groups
    ADD CONSTRAINT usuarios_usuario_groups_usuario_id_group_id_4ed5b09e_uniq UNIQUE (usuario_id, group_id);
 {   ALTER TABLE ONLY public.usuarios_usuario_groups DROP CONSTRAINT usuarios_usuario_groups_usuario_id_group_id_4ed5b09e_uniq;
       public            postgres    false    256    256            �           2606    20168 &   usuarios_usuario usuarios_usuario_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.usuarios_usuario
    ADD CONSTRAINT usuarios_usuario_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.usuarios_usuario DROP CONSTRAINT usuarios_usuario_pkey;
       public            postgres    false    255            �           2606    20170 a   usuarios_usuario_user_permissions usuarios_usuario_user_pe_usuario_id_permission_id_217cadcd_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.usuarios_usuario_user_permissions
    ADD CONSTRAINT usuarios_usuario_user_pe_usuario_id_permission_id_217cadcd_uniq UNIQUE (usuario_id, permission_id);
 �   ALTER TABLE ONLY public.usuarios_usuario_user_permissions DROP CONSTRAINT usuarios_usuario_user_pe_usuario_id_permission_id_217cadcd_uniq;
       public            postgres    false    259    259            �           2606    20172 H   usuarios_usuario_user_permissions usuarios_usuario_user_permissions_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.usuarios_usuario_user_permissions
    ADD CONSTRAINT usuarios_usuario_user_permissions_pkey PRIMARY KEY (id);
 r   ALTER TABLE ONLY public.usuarios_usuario_user_permissions DROP CONSTRAINT usuarios_usuario_user_permissions_pkey;
       public            postgres    false    259            �           2606    20174 .   usuarios_usuario usuarios_usuario_username_key 
   CONSTRAINT     m   ALTER TABLE ONLY public.usuarios_usuario
    ADD CONSTRAINT usuarios_usuario_username_key UNIQUE (username);
 X   ALTER TABLE ONLY public.usuarios_usuario DROP CONSTRAINT usuarios_usuario_username_key;
       public            postgres    false    255            �           2606    20176 *   ventas_correlativo ventas_correlativo_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.ventas_correlativo
    ADD CONSTRAINT ventas_correlativo_pkey PRIMARY KEY (id_correlativo);
 T   ALTER TABLE ONLY public.ventas_correlativo DROP CONSTRAINT ventas_correlativo_pkey;
       public            postgres    false    261            �           2606    20178 ,   ventas_detalleventa ventas_detalleventa_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.ventas_detalleventa
    ADD CONSTRAINT ventas_detalleventa_pkey PRIMARY KEY (id_detalle_venta);
 V   ALTER TABLE ONLY public.ventas_detalleventa DROP CONSTRAINT ventas_detalleventa_pkey;
       public            postgres    false    263            �           2606    20180 &   ventas_parametro ventas_parametro_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.ventas_parametro
    ADD CONSTRAINT ventas_parametro_pkey PRIMARY KEY (id_parametro);
 P   ALTER TABLE ONLY public.ventas_parametro DROP CONSTRAINT ventas_parametro_pkey;
       public            postgres    false    265            �           2606    20182 2   ventas_tipocomprobante ventas_tipocomprobante_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.ventas_tipocomprobante
    ADD CONSTRAINT ventas_tipocomprobante_pkey PRIMARY KEY (id_tipo_comprobante);
 \   ALTER TABLE ONLY public.ventas_tipocomprobante DROP CONSTRAINT ventas_tipocomprobante_pkey;
       public            postgres    false    267            �           2606    20184    ventas_venta ventas_venta_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.ventas_venta
    ADD CONSTRAINT ventas_venta_pkey PRIMARY KEY (id_venta);
 H   ALTER TABLE ONLY public.ventas_venta DROP CONSTRAINT ventas_venta_pkey;
       public            postgres    false    269            8           1259    20185    auth_group_name_a6ea08ec_like    INDEX     h   CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);
 1   DROP INDEX public.auth_group_name_a6ea08ec_like;
       public            postgres    false    202            =           1259    20186 (   auth_group_permissions_group_id_b120cbf9    INDEX     o   CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);
 <   DROP INDEX public.auth_group_permissions_group_id_b120cbf9;
       public            postgres    false    204            @           1259    20187 -   auth_group_permissions_permission_id_84c5c92e    INDEX     y   CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);
 A   DROP INDEX public.auth_group_permissions_permission_id_84c5c92e;
       public            postgres    false    204            C           1259    20188 (   auth_permission_content_type_id_2f476e4b    INDEX     o   CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);
 <   DROP INDEX public.auth_permission_content_type_id_2f476e4b;
       public            postgres    false    206            H           1259    20189 '   compras_compra_id_proveedor_id_e8c9f963    INDEX     m   CREATE INDEX compras_compra_id_proveedor_id_e8c9f963 ON public.compras_compra USING btree (id_proveedor_id);
 ;   DROP INDEX public.compras_compra_id_proveedor_id_e8c9f963;
       public            postgres    false    208            I           1259    20190 &   compras_compra_id_sucursal_id_c93d4dbf    INDEX     k   CREATE INDEX compras_compra_id_sucursal_id_c93d4dbf ON public.compras_compra USING btree (id_sucursal_id);
 :   DROP INDEX public.compras_compra_id_sucursal_id_c93d4dbf;
       public            postgres    false    208            J           1259    20191 .   compras_compra_id_tipo_comprobante_id_c6a9a18f    INDEX     {   CREATE INDEX compras_compra_id_tipo_comprobante_id_c6a9a18f ON public.compras_compra USING btree (id_tipo_comprobante_id);
 B   DROP INDEX public.compras_compra_id_tipo_comprobante_id_c6a9a18f;
       public            postgres    false    208            K           1259    20192 %   compras_compra_id_usuario_id_b45f96a8    INDEX     i   CREATE INDEX compras_compra_id_usuario_id_b45f96a8 ON public.compras_compra USING btree (id_usuario_id);
 9   DROP INDEX public.compras_compra_id_usuario_id_b45f96a8;
       public            postgres    false    208            N           1259    20193 +   compras_detallecompra_id_compra_id_d0df6c40    INDEX     u   CREATE INDEX compras_detallecompra_id_compra_id_d0df6c40 ON public.compras_detallecompra USING btree (id_compra_id);
 ?   DROP INDEX public.compras_detallecompra_id_compra_id_d0df6c40;
       public            postgres    false    209            O           1259    20194 -   compras_detallecompra_id_producto_id_5096e980    INDEX     y   CREATE INDEX compras_detallecompra_id_producto_id_5096e980 ON public.compras_detallecompra USING btree (id_producto_id);
 A   DROP INDEX public.compras_detallecompra_id_producto_id_5096e980;
       public            postgres    false    209            R           1259    20195 (   compras_proveedor_id_empresa_id_125fc2a7    INDEX     o   CREATE INDEX compras_proveedor_id_empresa_id_125fc2a7 ON public.compras_proveedor USING btree (id_empresa_id);
 <   DROP INDEX public.compras_proveedor_id_empresa_id_125fc2a7;
       public            postgres    false    211            S           1259    20196 /   compras_proveedor_id_tipo_documento_id_396911c6    INDEX     }   CREATE INDEX compras_proveedor_id_tipo_documento_id_396911c6 ON public.compras_proveedor USING btree (id_tipo_documento_id);
 C   DROP INDEX public.compras_proveedor_id_tipo_documento_id_396911c6;
       public            postgres    false    211            V           1259    20197 )   django_admin_log_content_type_id_c4bce8eb    INDEX     q   CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);
 =   DROP INDEX public.django_admin_log_content_type_id_c4bce8eb;
       public            postgres    false    213            Y           1259    20198 !   django_admin_log_user_id_c564eba6    INDEX     a   CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);
 5   DROP INDEX public.django_admin_log_user_id_c564eba6;
       public            postgres    false    213            `           1259    20199 #   django_session_expire_date_a5c62663    INDEX     e   CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);
 7   DROP INDEX public.django_session_expire_date_a5c62663;
       public            postgres    false    219            c           1259    20200 (   django_session_session_key_c0390e0f_like    INDEX     ~   CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);
 <   DROP INDEX public.django_session_session_key_c0390e0f_like;
       public            postgres    false    219            f           1259    20201 '   empresa_sucursal_id_empresa_id_ef35e990    INDEX     m   CREATE INDEX empresa_sucursal_id_empresa_id_ef35e990 ON public.empresa_sucursal USING btree (id_empresa_id);
 ;   DROP INDEX public.empresa_sucursal_id_empresa_id_ef35e990;
       public            postgres    false    222            i           1259    20202 %   gestion_animal_id_empresa_id_6ab826b4    INDEX     i   CREATE INDEX gestion_animal_id_empresa_id_6ab826b4 ON public.gestion_animal USING btree (id_empresa_id);
 9   DROP INDEX public.gestion_animal_id_empresa_id_6ab826b4;
       public            postgres    false    224            l           1259    20203 '   gestion_atencion_id_mascota_id_216f08ac    INDEX     m   CREATE INDEX gestion_atencion_id_mascota_id_216f08ac ON public.gestion_atencion USING btree (id_mascota_id);
 ;   DROP INDEX public.gestion_atencion_id_mascota_id_216f08ac;
       public            postgres    false    226            m           1259    20204 +   gestion_atencion_id_metodo_pago_id_2486359b    INDEX     u   CREATE INDEX gestion_atencion_id_metodo_pago_id_2486359b ON public.gestion_atencion USING btree (id_metodo_pago_id);
 ?   DROP INDEX public.gestion_atencion_id_metodo_pago_id_2486359b;
       public            postgres    false    226            n           1259    20205 (   gestion_atencion_id_sucursal_id_6df61897    INDEX     o   CREATE INDEX gestion_atencion_id_sucursal_id_6df61897 ON public.gestion_atencion USING btree (id_sucursal_id);
 <   DROP INDEX public.gestion_atencion_id_sucursal_id_6df61897;
       public            postgres    false    226            q           1259    20206 $   gestion_atencion_usuario_id_58e7b2c5    INDEX     g   CREATE INDEX gestion_atencion_usuario_id_58e7b2c5 ON public.gestion_atencion USING btree (usuario_id);
 8   DROP INDEX public.gestion_atencion_usuario_id_58e7b2c5;
       public            postgres    false    226            r           1259    20207 &   gestion_cliente_id_empresa_id_bff19218    INDEX     k   CREATE INDEX gestion_cliente_id_empresa_id_bff19218 ON public.gestion_cliente USING btree (id_empresa_id);
 :   DROP INDEX public.gestion_cliente_id_empresa_id_bff19218;
       public            postgres    false    227            s           1259    20208 '   gestion_cliente_id_sucursal_id_366414fa    INDEX     m   CREATE INDEX gestion_cliente_id_sucursal_id_366414fa ON public.gestion_cliente USING btree (id_sucursal_id);
 ;   DROP INDEX public.gestion_cliente_id_sucursal_id_366414fa;
       public            postgres    false    227            t           1259    20209 -   gestion_cliente_id_tipo_documento_id_86338929    INDEX     y   CREATE INDEX gestion_cliente_id_tipo_documento_id_86338929 ON public.gestion_cliente USING btree (id_tipo_documento_id);
 A   DROP INDEX public.gestion_cliente_id_tipo_documento_id_86338929;
       public            postgres    false    227            w           1259    20210 0   gestion_detalle_atencion_id_atencion_id_666fbfe1    INDEX        CREATE INDEX gestion_detalle_atencion_id_atencion_id_666fbfe1 ON public.gestion_detalle_atencion USING btree (id_atencion_id);
 D   DROP INDEX public.gestion_detalle_atencion_id_atencion_id_666fbfe1;
       public            postgres    false    229            x           1259    20211 0   gestion_detalle_atencion_id_servicio_id_a069048c    INDEX        CREATE INDEX gestion_detalle_atencion_id_servicio_id_a069048c ON public.gestion_detalle_atencion USING btree (id_servicio_id);
 D   DROP INDEX public.gestion_detalle_atencion_id_servicio_id_a069048c;
       public            postgres    false    229            {           1259    20212 &   gestion_mascota_id_cliente_id_a2eea1fc    INDEX     k   CREATE INDEX gestion_mascota_id_cliente_id_a2eea1fc ON public.gestion_mascota USING btree (id_cliente_id);
 :   DROP INDEX public.gestion_mascota_id_cliente_id_a2eea1fc;
       public            postgres    false    231            |           1259    20213 &   gestion_mascota_id_empresa_id_c949bb9c    INDEX     k   CREATE INDEX gestion_mascota_id_empresa_id_c949bb9c ON public.gestion_mascota USING btree (id_empresa_id);
 :   DROP INDEX public.gestion_mascota_id_empresa_id_c949bb9c;
       public            postgres    false    231            }           1259    20214 #   gestion_mascota_id_raza_id_cdcd87e5    INDEX     e   CREATE INDEX gestion_mascota_id_raza_id_cdcd87e5 ON public.gestion_mascota USING btree (id_raza_id);
 7   DROP INDEX public.gestion_mascota_id_raza_id_cdcd87e5;
       public            postgres    false    231            ~           1259    20215 '   gestion_mascota_id_sucursal_id_ed50a9b4    INDEX     m   CREATE INDEX gestion_mascota_id_sucursal_id_ed50a9b4 ON public.gestion_mascota USING btree (id_sucursal_id);
 ;   DROP INDEX public.gestion_mascota_id_sucursal_id_ed50a9b4;
       public            postgres    false    231            �           1259    20216 "   gestion_raza_id_animal_id_70a7f711    INDEX     c   CREATE INDEX gestion_raza_id_animal_id_70a7f711 ON public.gestion_raza USING btree (id_animal_id);
 6   DROP INDEX public.gestion_raza_id_animal_id_70a7f711;
       public            postgres    false    235            �           1259    20218 #   gestion_raza_id_empresa_id_d9185164    INDEX     e   CREATE INDEX gestion_raza_id_empresa_id_d9185164 ON public.gestion_raza USING btree (id_empresa_id);
 7   DROP INDEX public.gestion_raza_id_empresa_id_d9185164;
       public            postgres    false    235            �           1259    20219 +   gestion_recordatorio_id_empresa_id_84586fe0    INDEX     u   CREATE INDEX gestion_recordatorio_id_empresa_id_84586fe0 ON public.gestion_recordatorio USING btree (id_empresa_id);
 ?   DROP INDEX public.gestion_recordatorio_id_empresa_id_84586fe0;
       public            postgres    false    237            �           1259    20220 +   gestion_recordatorio_id_mascota_id_dacd34b5    INDEX     u   CREATE INDEX gestion_recordatorio_id_mascota_id_dacd34b5 ON public.gestion_recordatorio USING btree (id_mascota_id);
 ?   DROP INDEX public.gestion_recordatorio_id_mascota_id_dacd34b5;
       public            postgres    false    237            �           1259    20221 ,   gestion_recordatorio_id_servicio_id_03c6a2eb    INDEX     w   CREATE INDEX gestion_recordatorio_id_servicio_id_03c6a2eb ON public.gestion_recordatorio USING btree (id_servicio_id);
 @   DROP INDEX public.gestion_recordatorio_id_servicio_id_03c6a2eb;
       public            postgres    false    237            �           1259    20222 ,   gestion_recordatorio_id_sucursal_id_f77fb56a    INDEX     w   CREATE INDEX gestion_recordatorio_id_sucursal_id_f77fb56a ON public.gestion_recordatorio USING btree (id_sucursal_id);
 @   DROP INDEX public.gestion_recordatorio_id_sucursal_id_f77fb56a;
       public            postgres    false    237            �           1259    20223 (   gestion_recordatorio_usuario_id_8511b5e8    INDEX     o   CREATE INDEX gestion_recordatorio_usuario_id_8511b5e8 ON public.gestion_recordatorio USING btree (usuario_id);
 <   DROP INDEX public.gestion_recordatorio_usuario_id_8511b5e8;
       public            postgres    false    237            �           1259    20224 (   gestion_servicio_id_sucursal_id_30cb538c    INDEX     o   CREATE INDEX gestion_servicio_id_sucursal_id_30cb538c ON public.gestion_servicio USING btree (id_sucursal_id);
 <   DROP INDEX public.gestion_servicio_id_sucursal_id_30cb538c;
       public            postgres    false    239            �           1259    20225 *   productos_categoria_id_empresa_id_050324e2    INDEX     s   CREATE INDEX productos_categoria_id_empresa_id_050324e2 ON public.productos_categoria USING btree (id_empresa_id);
 >   DROP INDEX public.productos_categoria_id_empresa_id_050324e2;
       public            postgres    false    243            �           1259    20226 +   productos_producto_id_categoria_id_e1144c9a    INDEX     u   CREATE INDEX productos_producto_id_categoria_id_e1144c9a ON public.productos_producto USING btree (id_categoria_id);
 ?   DROP INDEX public.productos_producto_id_categoria_id_e1144c9a;
       public            postgres    false    245            �           1259    20227 )   productos_producto_id_empresa_id_a084e049    INDEX     q   CREATE INDEX productos_producto_id_empresa_id_a084e049 ON public.productos_producto USING btree (id_empresa_id);
 =   DROP INDEX public.productos_producto_id_empresa_id_a084e049;
       public            postgres    false    245            �           1259    20228 /   productos_producto_id_unidad_medida_id_cbd927ca    INDEX     }   CREATE INDEX productos_producto_id_unidad_medida_id_cbd927ca ON public.productos_producto USING btree (id_unidad_medida_id);
 C   DROP INDEX public.productos_producto_id_unidad_medida_id_cbd927ca;
       public            postgres    false    245            �           1259    20229 2   productos_productosucursal_id_producto_id_c89d1cba    INDEX     �   CREATE INDEX productos_productosucursal_id_producto_id_c89d1cba ON public.productos_productosucursal USING btree (id_producto_id);
 F   DROP INDEX public.productos_productosucursal_id_producto_id_c89d1cba;
       public            postgres    false    247            �           1259    20230 2   productos_productosucursal_id_sucursal_id_b592f593    INDEX     �   CREATE INDEX productos_productosucursal_id_sucursal_id_b592f593 ON public.productos_productosucursal USING btree (id_sucursal_id);
 F   DROP INDEX public.productos_productosucursal_id_sucursal_id_b592f593;
       public            postgres    false    247            �           1259    20231 0   productos_unidadmedida_descripcion_33a2f3c8_like    INDEX     �   CREATE INDEX productos_unidadmedida_descripcion_33a2f3c8_like ON public.productos_unidadmedida USING btree (descripcion varchar_pattern_ops);
 D   DROP INDEX public.productos_unidadmedida_descripcion_33a2f3c8_like;
       public            postgres    false    249            �           1259    20232 -   productos_unidadmedida_id_empresa_id_822d244b    INDEX     y   CREATE INDEX productos_unidadmedida_id_empresa_id_822d244b ON public.productos_unidadmedida USING btree (id_empresa_id);
 A   DROP INDEX public.productos_unidadmedida_id_empresa_id_822d244b;
       public            postgres    false    249            �           1259    20233 +   report_definition_report_type_ae23b665_like    INDEX     �   CREATE INDEX report_definition_report_type_ae23b665_like ON public.report_definition USING btree (report_type varchar_pattern_ops);
 ?   DROP INDEX public.report_definition_report_type_ae23b665_like;
       public            postgres    false    251            �           1259    20234 )   usuarios_usuario_groups_group_id_e77f6dcf    INDEX     q   CREATE INDEX usuarios_usuario_groups_group_id_e77f6dcf ON public.usuarios_usuario_groups USING btree (group_id);
 =   DROP INDEX public.usuarios_usuario_groups_group_id_e77f6dcf;
       public            postgres    false    256            �           1259    20235 +   usuarios_usuario_groups_usuario_id_7a34077f    INDEX     u   CREATE INDEX usuarios_usuario_groups_usuario_id_7a34077f ON public.usuarios_usuario_groups USING btree (usuario_id);
 ?   DROP INDEX public.usuarios_usuario_groups_usuario_id_7a34077f;
       public            postgres    false    256            �           1259    20236 8   usuarios_usuario_user_permissions_permission_id_4e5c0f2f    INDEX     �   CREATE INDEX usuarios_usuario_user_permissions_permission_id_4e5c0f2f ON public.usuarios_usuario_user_permissions USING btree (permission_id);
 L   DROP INDEX public.usuarios_usuario_user_permissions_permission_id_4e5c0f2f;
       public            postgres    false    259            �           1259    20237 5   usuarios_usuario_user_permissions_usuario_id_60aeea80    INDEX     �   CREATE INDEX usuarios_usuario_user_permissions_usuario_id_60aeea80 ON public.usuarios_usuario_user_permissions USING btree (usuario_id);
 I   DROP INDEX public.usuarios_usuario_user_permissions_usuario_id_60aeea80;
       public            postgres    false    259            �           1259    20238 '   usuarios_usuario_username_be9def2b_like    INDEX     |   CREATE INDEX usuarios_usuario_username_be9def2b_like ON public.usuarios_usuario USING btree (username varchar_pattern_ops);
 ;   DROP INDEX public.usuarios_usuario_username_be9def2b_like;
       public            postgres    false    255            �           1259    20239 )   ventas_correlativo_id_empresa_id_204d2e77    INDEX     q   CREATE INDEX ventas_correlativo_id_empresa_id_204d2e77 ON public.ventas_correlativo USING btree (id_empresa_id);
 =   DROP INDEX public.ventas_correlativo_id_empresa_id_204d2e77;
       public            postgres    false    261            �           1259    20240 2   ventas_correlativo_id_tipo_comprobante_id_21ce1083    INDEX     �   CREATE INDEX ventas_correlativo_id_tipo_comprobante_id_21ce1083 ON public.ventas_correlativo USING btree (id_tipo_comprobante_id);
 F   DROP INDEX public.ventas_correlativo_id_tipo_comprobante_id_21ce1083;
       public            postgres    false    261            �           1259    20241 +   ventas_detalleventa_id_producto_id_901cf687    INDEX     u   CREATE INDEX ventas_detalleventa_id_producto_id_901cf687 ON public.ventas_detalleventa USING btree (id_producto_id);
 ?   DROP INDEX public.ventas_detalleventa_id_producto_id_901cf687;
       public            postgres    false    263            �           1259    20242 (   ventas_detalleventa_id_venta_id_55c94b1a    INDEX     o   CREATE INDEX ventas_detalleventa_id_venta_id_55c94b1a ON public.ventas_detalleventa USING btree (id_venta_id);
 <   DROP INDEX public.ventas_detalleventa_id_venta_id_55c94b1a;
       public            postgres    false    263            �           1259    20243 -   ventas_tipocomprobante_id_empresa_id_7a6bc338    INDEX     y   CREATE INDEX ventas_tipocomprobante_id_empresa_id_7a6bc338 ON public.ventas_tipocomprobante USING btree (id_empresa_id);
 A   DROP INDEX public.ventas_tipocomprobante_id_empresa_id_7a6bc338;
       public            postgres    false    267            �           1259    20244 #   ventas_venta_id_cliente_id_c7494267    INDEX     e   CREATE INDEX ventas_venta_id_cliente_id_c7494267 ON public.ventas_venta USING btree (id_cliente_id);
 7   DROP INDEX public.ventas_venta_id_cliente_id_c7494267;
       public            postgres    false    269            �           1259    20245 '   ventas_venta_id_metodo_pago_id_fb93562d    INDEX     m   CREATE INDEX ventas_venta_id_metodo_pago_id_fb93562d ON public.ventas_venta USING btree (id_metodo_pago_id);
 ;   DROP INDEX public.ventas_venta_id_metodo_pago_id_fb93562d;
       public            postgres    false    269            �           1259    20246 $   ventas_venta_id_sucursal_id_114858d8    INDEX     g   CREATE INDEX ventas_venta_id_sucursal_id_114858d8 ON public.ventas_venta USING btree (id_sucursal_id);
 8   DROP INDEX public.ventas_venta_id_sucursal_id_114858d8;
       public            postgres    false    269            �           1259    20247 ,   ventas_venta_id_tipo_comprobante_id_4a13d208    INDEX     w   CREATE INDEX ventas_venta_id_tipo_comprobante_id_4a13d208 ON public.ventas_venta USING btree (id_tipo_comprobante_id);
 @   DROP INDEX public.ventas_venta_id_tipo_comprobante_id_4a13d208;
       public            postgres    false    269            �           1259    20248 #   ventas_venta_id_usuario_id_3dfb99f4    INDEX     e   CREATE INDEX ventas_venta_id_usuario_id_3dfb99f4 ON public.ventas_venta USING btree (id_usuario_id);
 7   DROP INDEX public.ventas_venta_id_usuario_id_3dfb99f4;
       public            postgres    false    269            �           2606    20249 O   auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm;
       public          postgres    false    3143    206    204            �           2606    20254 P   auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id;
       public          postgres    false    204    202    3132            �           2606    20259 E   auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 o   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co;
       public          postgres    false    215    3165    206            �           2606    20264 C   compras_compra compras_compra_id_proveedor_id_e8c9f963_fk_compras_p    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras_compra
    ADD CONSTRAINT compras_compra_id_proveedor_id_e8c9f963_fk_compras_p FOREIGN KEY (id_proveedor_id) REFERENCES public.compras_proveedor(id_proveedor) DEFERRABLE INITIALLY DEFERRED;
 m   ALTER TABLE ONLY public.compras_compra DROP CONSTRAINT compras_compra_id_proveedor_id_e8c9f963_fk_compras_p;
       public          postgres    false    3157    211    208            �           2606    20269 B   compras_compra compras_compra_id_sucursal_id_c93d4dbf_fk_empresa_s    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras_compra
    ADD CONSTRAINT compras_compra_id_sucursal_id_c93d4dbf_fk_empresa_s FOREIGN KEY (id_sucursal_id) REFERENCES public.empresa_sucursal(id_sucursal) DEFERRABLE INITIALLY DEFERRED;
 l   ALTER TABLE ONLY public.compras_compra DROP CONSTRAINT compras_compra_id_sucursal_id_c93d4dbf_fk_empresa_s;
       public          postgres    false    208    222    3176            �           2606    20274 H   compras_compra compras_compra_id_tipo_comprobante__c6a9a18f_fk_ventas_ti    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras_compra
    ADD CONSTRAINT compras_compra_id_tipo_comprobante__c6a9a18f_fk_ventas_ti FOREIGN KEY (id_tipo_comprobante_id) REFERENCES public.ventas_tipocomprobante(id_tipo_comprobante) DEFERRABLE INITIALLY DEFERRED;
 r   ALTER TABLE ONLY public.compras_compra DROP CONSTRAINT compras_compra_id_tipo_comprobante__c6a9a18f_fk_ventas_ti;
       public          postgres    false    267    208    3273            �           2606    20279 K   compras_compra compras_compra_id_usuario_id_b45f96a8_fk_usuarios_usuario_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras_compra
    ADD CONSTRAINT compras_compra_id_usuario_id_b45f96a8_fk_usuarios_usuario_id FOREIGN KEY (id_usuario_id) REFERENCES public.usuarios_usuario(id) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.compras_compra DROP CONSTRAINT compras_compra_id_usuario_id_b45f96a8_fk_usuarios_usuario_id;
       public          postgres    false    255    3245    208            �           2606    20284 M   compras_detallecompra compras_detallecompr_id_compra_id_d0df6c40_fk_compras_c    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras_detallecompra
    ADD CONSTRAINT compras_detallecompr_id_compra_id_d0df6c40_fk_compras_c FOREIGN KEY (id_compra_id) REFERENCES public.compras_compra(id_compra) DEFERRABLE INITIALLY DEFERRED;
 w   ALTER TABLE ONLY public.compras_detallecompra DROP CONSTRAINT compras_detallecompr_id_compra_id_d0df6c40_fk_compras_c;
       public          postgres    false    3149    209    208            �           2606    20289 O   compras_detallecompra compras_detallecompr_id_producto_id_5096e980_fk_productos    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras_detallecompra
    ADD CONSTRAINT compras_detallecompr_id_producto_id_5096e980_fk_productos FOREIGN KEY (id_producto_id) REFERENCES public.productos_producto(id_producto) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.compras_detallecompra DROP CONSTRAINT compras_detallecompr_id_producto_id_5096e980_fk_productos;
       public          postgres    false    3226    209    245            �           2606    20294 P   compras_proveedor compras_proveedor_id_empresa_id_125fc2a7_fk_empresa_empresa_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras_proveedor
    ADD CONSTRAINT compras_proveedor_id_empresa_id_125fc2a7_fk_empresa_empresa_id FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public.compras_proveedor DROP CONSTRAINT compras_proveedor_id_empresa_id_125fc2a7_fk_empresa_empresa_id;
       public          postgres    false    220    211    3173            �           2606    20299 N   compras_proveedor compras_proveedor_id_tipo_documento_id_396911c6_fk_gestion_t    FK CONSTRAINT     �   ALTER TABLE ONLY public.compras_proveedor
    ADD CONSTRAINT compras_proveedor_id_tipo_documento_id_396911c6_fk_gestion_t FOREIGN KEY (id_tipo_documento_id) REFERENCES public.gestion_tipodocumento(id_tipo_documento) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.compras_proveedor DROP CONSTRAINT compras_proveedor_id_tipo_documento_id_396911c6_fk_gestion_t;
       public          postgres    false    3218    211    241            �           2606    20304 G   django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 q   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co;
       public          postgres    false    215    213    3165            �           2606    20309 I   django_admin_log django_admin_log_user_id_c564eba6_fk_usuarios_usuario_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_usuarios_usuario_id FOREIGN KEY (user_id) REFERENCES public.usuarios_usuario(id) DEFERRABLE INITIALLY DEFERRED;
 s   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_user_id_c564eba6_fk_usuarios_usuario_id;
       public          postgres    false    255    213    3245            �           2606    20314 N   empresa_sucursal empresa_sucursal_id_empresa_id_ef35e990_fk_empresa_empresa_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.empresa_sucursal
    ADD CONSTRAINT empresa_sucursal_id_empresa_id_ef35e990_fk_empresa_empresa_id FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.empresa_sucursal DROP CONSTRAINT empresa_sucursal_id_empresa_id_ef35e990_fk_empresa_empresa_id;
       public          postgres    false    220    222    3173            �           2606    20319 J   gestion_animal gestion_animal_id_empresa_id_6ab826b4_fk_empresa_empresa_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_animal
    ADD CONSTRAINT gestion_animal_id_empresa_id_6ab826b4_fk_empresa_empresa_id FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 t   ALTER TABLE ONLY public.gestion_animal DROP CONSTRAINT gestion_animal_id_empresa_id_6ab826b4_fk_empresa_empresa_id;
       public          postgres    false    220    224    3173            �           2606    20324 E   gestion_atencion gestion_atencion_id_mascota_id_216f08ac_fk_gestion_m    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_atencion
    ADD CONSTRAINT gestion_atencion_id_mascota_id_216f08ac_fk_gestion_m FOREIGN KEY (id_mascota_id) REFERENCES public.gestion_mascota(id_mascota) DEFERRABLE INITIALLY DEFERRED;
 o   ALTER TABLE ONLY public.gestion_atencion DROP CONSTRAINT gestion_atencion_id_mascota_id_216f08ac_fk_gestion_m;
       public          postgres    false    3200    226    231            �           2606    20329 I   gestion_atencion gestion_atencion_id_metodo_pago_id_2486359b_fk_gestion_m    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_atencion
    ADD CONSTRAINT gestion_atencion_id_metodo_pago_id_2486359b_fk_gestion_m FOREIGN KEY (id_metodo_pago_id) REFERENCES public.gestion_metodopago(id_metodo_pago) DEFERRABLE INITIALLY DEFERRED;
 s   ALTER TABLE ONLY public.gestion_atencion DROP CONSTRAINT gestion_atencion_id_metodo_pago_id_2486359b_fk_gestion_m;
       public          postgres    false    233    226    3202            �           2606    20334 F   gestion_atencion gestion_atencion_id_sucursal_id_6df61897_fk_empresa_s    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_atencion
    ADD CONSTRAINT gestion_atencion_id_sucursal_id_6df61897_fk_empresa_s FOREIGN KEY (id_sucursal_id) REFERENCES public.empresa_sucursal(id_sucursal) DEFERRABLE INITIALLY DEFERRED;
 p   ALTER TABLE ONLY public.gestion_atencion DROP CONSTRAINT gestion_atencion_id_sucursal_id_6df61897_fk_empresa_s;
       public          postgres    false    226    222    3176            �           2606    20339 L   gestion_atencion gestion_atencion_usuario_id_58e7b2c5_fk_usuarios_usuario_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_atencion
    ADD CONSTRAINT gestion_atencion_usuario_id_58e7b2c5_fk_usuarios_usuario_id FOREIGN KEY (usuario_id) REFERENCES public.usuarios_usuario(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.gestion_atencion DROP CONSTRAINT gestion_atencion_usuario_id_58e7b2c5_fk_usuarios_usuario_id;
       public          postgres    false    3245    255    226            �           2606    20344 L   gestion_cliente gestion_cliente_id_empresa_id_bff19218_fk_empresa_empresa_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_cliente
    ADD CONSTRAINT gestion_cliente_id_empresa_id_bff19218_fk_empresa_empresa_id FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.gestion_cliente DROP CONSTRAINT gestion_cliente_id_empresa_id_bff19218_fk_empresa_empresa_id;
       public          postgres    false    227    220    3173            �           2606    20349 D   gestion_cliente gestion_cliente_id_sucursal_id_366414fa_fk_empresa_s    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_cliente
    ADD CONSTRAINT gestion_cliente_id_sucursal_id_366414fa_fk_empresa_s FOREIGN KEY (id_sucursal_id) REFERENCES public.empresa_sucursal(id_sucursal) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.gestion_cliente DROP CONSTRAINT gestion_cliente_id_sucursal_id_366414fa_fk_empresa_s;
       public          postgres    false    227    222    3176            �           2606    20354 J   gestion_cliente gestion_cliente_id_tipo_documento_id_86338929_fk_gestion_t    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_cliente
    ADD CONSTRAINT gestion_cliente_id_tipo_documento_id_86338929_fk_gestion_t FOREIGN KEY (id_tipo_documento_id) REFERENCES public.gestion_tipodocumento(id_tipo_documento) DEFERRABLE INITIALLY DEFERRED;
 t   ALTER TABLE ONLY public.gestion_cliente DROP CONSTRAINT gestion_cliente_id_tipo_documento_id_86338929_fk_gestion_t;
       public          postgres    false    227    241    3218            �           2606    20359 R   gestion_detalle_atencion gestion_detalle_aten_id_atencion_id_666fbfe1_fk_gestion_a    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_detalle_atencion
    ADD CONSTRAINT gestion_detalle_aten_id_atencion_id_666fbfe1_fk_gestion_a FOREIGN KEY (id_atencion_id) REFERENCES public.gestion_atencion(id_atencion) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.gestion_detalle_atencion DROP CONSTRAINT gestion_detalle_aten_id_atencion_id_666fbfe1_fk_gestion_a;
       public          postgres    false    3184    226    229            �           2606    20364 R   gestion_detalle_atencion gestion_detalle_aten_id_servicio_id_a069048c_fk_gestion_s    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_detalle_atencion
    ADD CONSTRAINT gestion_detalle_aten_id_servicio_id_a069048c_fk_gestion_s FOREIGN KEY (id_servicio_id) REFERENCES public.gestion_servicio(id_servicio) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.gestion_detalle_atencion DROP CONSTRAINT gestion_detalle_aten_id_servicio_id_a069048c_fk_gestion_s;
       public          postgres    false    239    3216    229            �           2606    20369 C   gestion_mascota gestion_mascota_id_cliente_id_a2eea1fc_fk_gestion_c    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_mascota
    ADD CONSTRAINT gestion_mascota_id_cliente_id_a2eea1fc_fk_gestion_c FOREIGN KEY (id_cliente_id) REFERENCES public.gestion_cliente(id_cliente) DEFERRABLE INITIALLY DEFERRED;
 m   ALTER TABLE ONLY public.gestion_mascota DROP CONSTRAINT gestion_mascota_id_cliente_id_a2eea1fc_fk_gestion_c;
       public          postgres    false    227    231    3190            �           2606    20374 L   gestion_mascota gestion_mascota_id_empresa_id_c949bb9c_fk_empresa_empresa_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_mascota
    ADD CONSTRAINT gestion_mascota_id_empresa_id_c949bb9c_fk_empresa_empresa_id FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.gestion_mascota DROP CONSTRAINT gestion_mascota_id_empresa_id_c949bb9c_fk_empresa_empresa_id;
       public          postgres    false    3173    231    220            �           2606    20379 K   gestion_mascota gestion_mascota_id_raza_id_cdcd87e5_fk_gestion_raza_id_raza    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_mascota
    ADD CONSTRAINT gestion_mascota_id_raza_id_cdcd87e5_fk_gestion_raza_id_raza FOREIGN KEY (id_raza_id) REFERENCES public.gestion_raza(id_raza) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.gestion_mascota DROP CONSTRAINT gestion_mascota_id_raza_id_cdcd87e5_fk_gestion_raza_id_raza;
       public          postgres    false    3206    231    235            �           2606    20384 D   gestion_mascota gestion_mascota_id_sucursal_id_ed50a9b4_fk_empresa_s    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_mascota
    ADD CONSTRAINT gestion_mascota_id_sucursal_id_ed50a9b4_fk_empresa_s FOREIGN KEY (id_sucursal_id) REFERENCES public.empresa_sucursal(id_sucursal) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.gestion_mascota DROP CONSTRAINT gestion_mascota_id_sucursal_id_ed50a9b4_fk_empresa_s;
       public          postgres    false    231    222    3176            �           2606    20389 K   gestion_raza gestion_raza_id_animal_id_70a7f711_fk_gestion_animal_id_animal    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_raza
    ADD CONSTRAINT gestion_raza_id_animal_id_70a7f711_fk_gestion_animal_id_animal FOREIGN KEY (id_animal_id) REFERENCES public.gestion_animal(id_animal) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.gestion_raza DROP CONSTRAINT gestion_raza_id_animal_id_70a7f711_fk_gestion_animal_id_animal;
       public          postgres    false    235    3179    224            �           2606    20394 F   gestion_raza gestion_raza_id_empresa_id_d9185164_fk_empresa_empresa_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_raza
    ADD CONSTRAINT gestion_raza_id_empresa_id_d9185164_fk_empresa_empresa_id FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 p   ALTER TABLE ONLY public.gestion_raza DROP CONSTRAINT gestion_raza_id_empresa_id_d9185164_fk_empresa_empresa_id;
       public          postgres    false    235    3173    220            �           2606    20399 M   gestion_recordatorio gestion_recordatorio_id_empresa_id_84586fe0_fk_empresa_e    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_recordatorio
    ADD CONSTRAINT gestion_recordatorio_id_empresa_id_84586fe0_fk_empresa_e FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 w   ALTER TABLE ONLY public.gestion_recordatorio DROP CONSTRAINT gestion_recordatorio_id_empresa_id_84586fe0_fk_empresa_e;
       public          postgres    false    237    3173    220            �           2606    20404 M   gestion_recordatorio gestion_recordatorio_id_mascota_id_dacd34b5_fk_gestion_m    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_recordatorio
    ADD CONSTRAINT gestion_recordatorio_id_mascota_id_dacd34b5_fk_gestion_m FOREIGN KEY (id_mascota_id) REFERENCES public.gestion_mascota(id_mascota) DEFERRABLE INITIALLY DEFERRED;
 w   ALTER TABLE ONLY public.gestion_recordatorio DROP CONSTRAINT gestion_recordatorio_id_mascota_id_dacd34b5_fk_gestion_m;
       public          postgres    false    237    3200    231            �           2606    20409 N   gestion_recordatorio gestion_recordatorio_id_servicio_id_03c6a2eb_fk_gestion_s    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_recordatorio
    ADD CONSTRAINT gestion_recordatorio_id_servicio_id_03c6a2eb_fk_gestion_s FOREIGN KEY (id_servicio_id) REFERENCES public.gestion_servicio(id_servicio) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.gestion_recordatorio DROP CONSTRAINT gestion_recordatorio_id_servicio_id_03c6a2eb_fk_gestion_s;
       public          postgres    false    237    3216    239            �           2606    20414 N   gestion_recordatorio gestion_recordatorio_id_sucursal_id_f77fb56a_fk_empresa_s    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_recordatorio
    ADD CONSTRAINT gestion_recordatorio_id_sucursal_id_f77fb56a_fk_empresa_s FOREIGN KEY (id_sucursal_id) REFERENCES public.empresa_sucursal(id_sucursal) DEFERRABLE INITIALLY DEFERRED;
 x   ALTER TABLE ONLY public.gestion_recordatorio DROP CONSTRAINT gestion_recordatorio_id_sucursal_id_f77fb56a_fk_empresa_s;
       public          postgres    false    3176    222    237            �           2606    20419 T   gestion_recordatorio gestion_recordatorio_usuario_id_8511b5e8_fk_usuarios_usuario_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_recordatorio
    ADD CONSTRAINT gestion_recordatorio_usuario_id_8511b5e8_fk_usuarios_usuario_id FOREIGN KEY (usuario_id) REFERENCES public.usuarios_usuario(id) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.gestion_recordatorio DROP CONSTRAINT gestion_recordatorio_usuario_id_8511b5e8_fk_usuarios_usuario_id;
       public          postgres    false    255    3245    237            �           2606    20424 F   gestion_servicio gestion_servicio_id_sucursal_id_30cb538c_fk_empresa_s    FK CONSTRAINT     �   ALTER TABLE ONLY public.gestion_servicio
    ADD CONSTRAINT gestion_servicio_id_sucursal_id_30cb538c_fk_empresa_s FOREIGN KEY (id_sucursal_id) REFERENCES public.empresa_sucursal(id_sucursal) DEFERRABLE INITIALLY DEFERRED;
 p   ALTER TABLE ONLY public.gestion_servicio DROP CONSTRAINT gestion_servicio_id_sucursal_id_30cb538c_fk_empresa_s;
       public          postgres    false    222    3176    239            �           2606    20429 K   productos_categoria productos_categoria_id_empresa_id_050324e2_fk_empresa_e    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos_categoria
    ADD CONSTRAINT productos_categoria_id_empresa_id_050324e2_fk_empresa_e FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.productos_categoria DROP CONSTRAINT productos_categoria_id_empresa_id_050324e2_fk_empresa_e;
       public          postgres    false    243    220    3173            �           2606    20434 K   productos_producto productos_producto_id_categoria_id_e1144c9a_fk_productos    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos_producto
    ADD CONSTRAINT productos_producto_id_categoria_id_e1144c9a_fk_productos FOREIGN KEY (id_categoria_id) REFERENCES public.productos_categoria(id_categoria) DEFERRABLE INITIALLY DEFERRED;
 u   ALTER TABLE ONLY public.productos_producto DROP CONSTRAINT productos_producto_id_categoria_id_e1144c9a_fk_productos;
       public          postgres    false    243    3221    245            �           2606    20439 R   productos_producto productos_producto_id_empresa_id_a084e049_fk_empresa_empresa_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos_producto
    ADD CONSTRAINT productos_producto_id_empresa_id_a084e049_fk_empresa_empresa_id FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.productos_producto DROP CONSTRAINT productos_producto_id_empresa_id_a084e049_fk_empresa_empresa_id;
       public          postgres    false    245    3173    220            �           2606    20444 O   productos_producto productos_producto_id_unidad_medida_id_cbd927ca_fk_productos    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos_producto
    ADD CONSTRAINT productos_producto_id_unidad_medida_id_cbd927ca_fk_productos FOREIGN KEY (id_unidad_medida_id) REFERENCES public.productos_unidadmedida(id_unidad_medida) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.productos_producto DROP CONSTRAINT productos_producto_id_unidad_medida_id_cbd927ca_fk_productos;
       public          postgres    false    245    3236    249            �           2606    20449 T   productos_productosucursal productos_productosu_id_producto_id_c89d1cba_fk_productos    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos_productosucursal
    ADD CONSTRAINT productos_productosu_id_producto_id_c89d1cba_fk_productos FOREIGN KEY (id_producto_id) REFERENCES public.productos_producto(id_producto) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.productos_productosucursal DROP CONSTRAINT productos_productosu_id_producto_id_c89d1cba_fk_productos;
       public          postgres    false    247    3226    245            �           2606    20454 T   productos_productosucursal productos_productosu_id_sucursal_id_b592f593_fk_empresa_s    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos_productosucursal
    ADD CONSTRAINT productos_productosu_id_sucursal_id_b592f593_fk_empresa_s FOREIGN KEY (id_sucursal_id) REFERENCES public.empresa_sucursal(id_sucursal) DEFERRABLE INITIALLY DEFERRED;
 ~   ALTER TABLE ONLY public.productos_productosucursal DROP CONSTRAINT productos_productosu_id_sucursal_id_b592f593_fk_empresa_s;
       public          postgres    false    222    247    3176            �           2606    20459 O   productos_unidadmedida productos_unidadmedi_id_empresa_id_822d244b_fk_empresa_e    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos_unidadmedida
    ADD CONSTRAINT productos_unidadmedi_id_empresa_id_822d244b_fk_empresa_e FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.productos_unidadmedida DROP CONSTRAINT productos_unidadmedi_id_empresa_id_822d244b_fk_empresa_e;
       public          postgres    false    220    249    3173            �           2606    20464 M   usuarios_usuario_groups usuarios_usuario_gro_usuario_id_7a34077f_fk_usuarios_    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuarios_usuario_groups
    ADD CONSTRAINT usuarios_usuario_gro_usuario_id_7a34077f_fk_usuarios_ FOREIGN KEY (usuario_id) REFERENCES public.usuarios_usuario(id) DEFERRABLE INITIALLY DEFERRED;
 w   ALTER TABLE ONLY public.usuarios_usuario_groups DROP CONSTRAINT usuarios_usuario_gro_usuario_id_7a34077f_fk_usuarios_;
       public          postgres    false    3245    255    256            �           2606    20469 R   usuarios_usuario_groups usuarios_usuario_groups_group_id_e77f6dcf_fk_auth_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuarios_usuario_groups
    ADD CONSTRAINT usuarios_usuario_groups_group_id_e77f6dcf_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.usuarios_usuario_groups DROP CONSTRAINT usuarios_usuario_groups_group_id_e77f6dcf_fk_auth_group_id;
       public          postgres    false    202    256    3132            �           2606    20474 Z   usuarios_usuario_user_permissions usuarios_usuario_use_permission_id_4e5c0f2f_fk_auth_perm    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuarios_usuario_user_permissions
    ADD CONSTRAINT usuarios_usuario_use_permission_id_4e5c0f2f_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.usuarios_usuario_user_permissions DROP CONSTRAINT usuarios_usuario_use_permission_id_4e5c0f2f_fk_auth_perm;
       public          postgres    false    259    206    3143            �           2606    20479 W   usuarios_usuario_user_permissions usuarios_usuario_use_usuario_id_60aeea80_fk_usuarios_    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuarios_usuario_user_permissions
    ADD CONSTRAINT usuarios_usuario_use_usuario_id_60aeea80_fk_usuarios_ FOREIGN KEY (usuario_id) REFERENCES public.usuarios_usuario(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.usuarios_usuario_user_permissions DROP CONSTRAINT usuarios_usuario_use_usuario_id_60aeea80_fk_usuarios_;
       public          postgres    false    259    255    3245                        2606    20484 R   ventas_correlativo ventas_correlativo_id_empresa_id_204d2e77_fk_empresa_empresa_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas_correlativo
    ADD CONSTRAINT ventas_correlativo_id_empresa_id_204d2e77_fk_empresa_empresa_id FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 |   ALTER TABLE ONLY public.ventas_correlativo DROP CONSTRAINT ventas_correlativo_id_empresa_id_204d2e77_fk_empresa_empresa_id;
       public          postgres    false    261    220    3173                       2606    20489 P   ventas_correlativo ventas_correlativo_id_tipo_comprobante__21ce1083_fk_ventas_ti    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas_correlativo
    ADD CONSTRAINT ventas_correlativo_id_tipo_comprobante__21ce1083_fk_ventas_ti FOREIGN KEY (id_tipo_comprobante_id) REFERENCES public.ventas_tipocomprobante(id_tipo_comprobante) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public.ventas_correlativo DROP CONSTRAINT ventas_correlativo_id_tipo_comprobante__21ce1083_fk_ventas_ti;
       public          postgres    false    267    261    3273                       2606    20494 L   ventas_detalleventa ventas_detalleventa_id_producto_id_901cf687_fk_productos    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas_detalleventa
    ADD CONSTRAINT ventas_detalleventa_id_producto_id_901cf687_fk_productos FOREIGN KEY (id_producto_id) REFERENCES public.productos_producto(id_producto) DEFERRABLE INITIALLY DEFERRED;
 v   ALTER TABLE ONLY public.ventas_detalleventa DROP CONSTRAINT ventas_detalleventa_id_producto_id_901cf687_fk_productos;
       public          postgres    false    263    3226    245                       2606    20499 I   ventas_detalleventa ventas_detalleventa_id_venta_id_55c94b1a_fk_ventas_ve    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas_detalleventa
    ADD CONSTRAINT ventas_detalleventa_id_venta_id_55c94b1a_fk_ventas_ve FOREIGN KEY (id_venta_id) REFERENCES public.ventas_venta(id_venta) DEFERRABLE INITIALLY DEFERRED;
 s   ALTER TABLE ONLY public.ventas_detalleventa DROP CONSTRAINT ventas_detalleventa_id_venta_id_55c94b1a_fk_ventas_ve;
       public          postgres    false    3280    263    269                       2606    20504 O   ventas_tipocomprobante ventas_tipocomproban_id_empresa_id_7a6bc338_fk_empresa_e    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas_tipocomprobante
    ADD CONSTRAINT ventas_tipocomproban_id_empresa_id_7a6bc338_fk_empresa_e FOREIGN KEY (id_empresa_id) REFERENCES public.empresa_empresa(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.ventas_tipocomprobante DROP CONSTRAINT ventas_tipocomproban_id_empresa_id_7a6bc338_fk_empresa_e;
       public          postgres    false    3173    220    267                       2606    20509 =   ventas_venta ventas_venta_id_cliente_id_c7494267_fk_gestion_c    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas_venta
    ADD CONSTRAINT ventas_venta_id_cliente_id_c7494267_fk_gestion_c FOREIGN KEY (id_cliente_id) REFERENCES public.gestion_cliente(id_cliente) DEFERRABLE INITIALLY DEFERRED;
 g   ALTER TABLE ONLY public.ventas_venta DROP CONSTRAINT ventas_venta_id_cliente_id_c7494267_fk_gestion_c;
       public          postgres    false    227    269    3190                       2606    20514 A   ventas_venta ventas_venta_id_metodo_pago_id_fb93562d_fk_gestion_m    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas_venta
    ADD CONSTRAINT ventas_venta_id_metodo_pago_id_fb93562d_fk_gestion_m FOREIGN KEY (id_metodo_pago_id) REFERENCES public.gestion_metodopago(id_metodo_pago) DEFERRABLE INITIALLY DEFERRED;
 k   ALTER TABLE ONLY public.ventas_venta DROP CONSTRAINT ventas_venta_id_metodo_pago_id_fb93562d_fk_gestion_m;
       public          postgres    false    3202    269    233                       2606    20519 >   ventas_venta ventas_venta_id_sucursal_id_114858d8_fk_empresa_s    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas_venta
    ADD CONSTRAINT ventas_venta_id_sucursal_id_114858d8_fk_empresa_s FOREIGN KEY (id_sucursal_id) REFERENCES public.empresa_sucursal(id_sucursal) DEFERRABLE INITIALLY DEFERRED;
 h   ALTER TABLE ONLY public.ventas_venta DROP CONSTRAINT ventas_venta_id_sucursal_id_114858d8_fk_empresa_s;
       public          postgres    false    222    269    3176                       2606    20524 D   ventas_venta ventas_venta_id_tipo_comprobante__4a13d208_fk_ventas_ti    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas_venta
    ADD CONSTRAINT ventas_venta_id_tipo_comprobante__4a13d208_fk_ventas_ti FOREIGN KEY (id_tipo_comprobante_id) REFERENCES public.ventas_tipocomprobante(id_tipo_comprobante) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.ventas_venta DROP CONSTRAINT ventas_venta_id_tipo_comprobante__4a13d208_fk_ventas_ti;
       public          postgres    false    3273    269    267            	           2606    20529 G   ventas_venta ventas_venta_id_usuario_id_3dfb99f4_fk_usuarios_usuario_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas_venta
    ADD CONSTRAINT ventas_venta_id_usuario_id_3dfb99f4_fk_usuarios_usuario_id FOREIGN KEY (id_usuario_id) REFERENCES public.usuarios_usuario(id) DEFERRABLE INITIALLY DEFERRED;
 q   ALTER TABLE ONLY public.ventas_venta DROP CONSTRAINT ventas_venta_id_usuario_id_3dfb99f4_fk_usuarios_usuario_id;
       public          postgres    false    255    3245    269            �      x�3�tO-J�+I����� !��      �   2  x���m 1C�s~1��˽��:bΉ:��~,pE�"M)�V,���?\�aG�)�I��Dyc�|0a��4���8��0\^8./��ˋ��˃��ח��//�w����e�	y9��\B^^B^B^!���WAȫ�0�꽌�jR^)���W��ׇ��F�k'�u��:Iy]��~O-����K��KɛC���S�&(y���)Z�4-o޿�7K˛K��C��ח��/o__޾�������[��ی�;����!�^��9�7�c�~�3�;�=ߑ�}G���N�� ϰ�ϲ����'�a?ٌ�ds�~�J�c�      �     x�u�ݎ�6��ŧ�'(,��2��r� I{U�`%�`[%�H��9��#�w��w���93������lӼ=���}�v��,B�O)�*R�?�~q��f��m��36�4���u�"9U4�g�ߍ�����栽��d+G�(d&'��G��{��wކ�Wl�	*MSn��L��/��O���猎v�ݲ�_o�z[�a��L��f�!����G��c�&Pt�ȑ}����Z죥�MyҞE�<kW
$[V�hL�������!�����3t?d��zb�3�ۉ�6��t��{{>�ч���Fg��dz�!r�!��D+���j���)���G�����!����O�jbzwz)]��}t�y����-tuW���!ԛ\3[��5��ɠ��ddy&S]�&��I��߯m(�"��89ң�B�+(O��A�+.O
�v���&Df��?l_w�-�4�o����D����W�bNu���+f$n�������(�Ŀ��T1;���6���Td�J����uEKj>�1\�U����g���h,�Iȑ&s��T��\J4S��o�?�P,ʴzz6{����e��<��T��\��LIJ>��^�n�K[>M�Mz��y�$�K1�酘��T�^H�	�BI�WWw��C�?IZ:^��28����q��c*�s>�e�%���H�P1N{��s�l�g���J`�\V��4ۄ�$�vo�L�5�	?eZfc��b�!�k���A	]S� �TZ�4�J 
I��5cVM�vპ����|Ag���|=gR%Ws�r��q�N.Z�l��xZ���o�����tv��6��N&2Il���]��v�i�V%_Kj)�d��P�M@)~�UЪ<�P�-t*ٝ��j���UE�r�dN�n��S��1�����#M�r+I�b���0-�G.�3���f�B���}%��2�������_����}N��e���e����DtB�Ww,��`��\Y���T��*�p�&U�Yߧ,��4KJ=y��5�/�C�8��j6k����v6]����扠y�0��"ND+3>`��p��%)c"� @��r^��t3d	~����~`a��#D�-��j�'D���E��kwy��UZ������X���[�*�@F���,�.}���e<}�U�w!��x!q
�8�����M<C�*���?�w{o�H�tI�^H=� d�B��.���U-_\Z�U%]a������]?�J���?��OI�p�:��L��X�:-Τ4�@�8�/���6m?���'5��/Ƙ�/go      �   p   x���1
�@�z��;V���څ_��/���]b�F�bѰr,�#�W%�-*
���'�O@g�&��%�Aӕ)�����õo���N��]Bˏ�^�x�Gab�yr��U3{i+-�      �   P   x�5���0��0`�f��?G�H_�N�Q@�>���.�QL*�mD�[�)�NAHj��]8��U"gl��6��'�A����      �   k   x�=�K
�0D�է����5������Ef�H��7B��G)�DM��w�/Rp��1�Fч�a�\v�맔ܱ�`���Y�).(�M�v���H�Z�'BkOD�G�      �   �	  x��Zm�������}i���w~s.�a�q�6�F�H<��N(�7�����%)�$׸>�����<3C��@y#�\�)̴I���F�	Lޗ�uU'�5�����lV̮��?��0Q��BfR��-C��v^.�i�<��|5������T&d�4�gMrC`��� ��+�ǒ�i��������s9�W#h:F�l8mE�&��u~7��b5�k��l��\5����=���A�1�ϴJ� �{v���0� t�"*B��S�(�b�.��},Ͼ�
c��A>�ݗ��$=��/>�뻲��V�ן����j�,��������|�ˇ�� �Z�O%����i�X�δK�k=�=�&�����{r��u�Y�:��>�2�BpƝ���:��KV�|���_��J0��'_����ֱ�ɀ�饕>î����Lc��V�������<�a�ji�n/�ͻ�1a	SdHVBBٝ7<�%�
|�K7Mg���=ѺX��b��%��tS��y � �B!+�Ȕ����#�K�cy���Wk��m�I����	��⁌�]�I8�e�yvWL���P0q ]��C(�Za���|o��s1Xf��"��2�x4�M?]�iY-����dL�W����y��/�*�[���$�ڇ B���J���͢��![�. %8�9��3텽)�U=�)���?���U����
�	Ѕ��`
��\��b�=��c�o�eU��YqG�k��	�\_���J���dYW���/[g>_��k�6E4.�!��v�)b%�	"Q�o��N�O~�
� �
�mH�f�@���׀.�£T!U*W�b�����ŝ�L��q�Ƈ�*ꇒ|���eSo�}(���E1k���jt_Sh+��dt�m�Xr�v@�ʄ0����.8E'�M2Ӳ!�ģ�$��?_={�t��5�n@�.�	6����۷�ތ#���N*�e��U]�kC�|G=��k�EC��@�8 d4���-}�����di���I�ؾ�-u�kNO�4�s�V=A�v���A'�D�=�
�Qd�"Ov�8�[�E�PA��Q�G�1
�h��7G��k�����*Y�2Z)�Ի���D��`�,���=�������d��H�c4ݡ��)����*.���ԩ���2���Ml#�~�p�
�'Z�6�([��Ohѕf�j2M�Dkkऎ���dY���jE٤��5�uH�Pb�e��gsd����e&S�:������)�6Ͻ��))P��VZ��y�w�o��}!�T84
���ʘ΄���0�Hؽ�J�������^��6�є�޶S�>�h�j?�Fn�B]�'�QیD��m�	i�@��x�B�Uc�;U�� �Z����(��d�
�"]��A�J�s��}�� ���=�`�dNzƌ �{������
�Tcɺ#��`�^�5�-��ް��sS�ك2���j+`{�()PSc�����0�tmǀ=g�MG��ѧ{¸7�� Y�������No{�D�VJ��h���ҟ0#�_����c<�����6���@���!��-t�>��0�X�o\������X$�������HS�?���s4�]��e������C�����A���\d�1��.�Dԣ{�K^�A�Q;.�@���ɘ���P��W�T:��gRF��Z��_�']yw��\�a���Խ��B��u���]���&�4d#��?�9�r��?v�mox�MY��e��>2�	��S�2d#7�S)��lҽ
�X��"ނ���Kbd��O���2d������D�α9�/cx�YKh����� '�q�����v��K^��:i��'A���� �\���3vKC/�7��t�fv혞��_;���:�� @O}Z7xDG'�-���Wc�h�js�I��I��<���6_$e�{�<A�ZS� 4;S)A���K�B7�J�4���9��x�%R�X'�/�v���#��f�G緓��r[��u���<����m��.�}82������i���>/�	�>�Pwo)�a��+��5P�+����}��Ur[��C�M������Um�h�8�Mr�����/c�8Pя!5�������ժ�Y,y"5��6��Ͳ[X^#B9�]��Y�RF�����ŝO��^����{��𩁈�z�*b	a�.'?��!� l�/ϝ��!��ɿ�D���8�jlJ�Ոv���ȶ�d��x���@L���)g}�,*"�u��h?��#�i].;��f*V�k;iMM������)c-��Ә"+���Z���m����ղ8O�a�I���,P��1٫r]�Lv��4�J~�	��J���.�b� ��9�ЛS������ݿ���������&�櫝y��\ph�|2����PQlQp�3�J�}�S�x�Kg5��;r2쫥�)�O�U�W�������M0�      �   B  x�m��n� ����L���]&MxR3������I�2�����`-�&��1���_2
���ZJ�&��	��I(c�p�$W_%�GSsE���Nf�\�%�K��ι�o�KOKL��Y�d��^�STD`mG3f������	G��� �i��e�5*{�,P�i�����cO�,��ؓI¡��"�^�"�'\�0�4��<U�	���}t֬*�f�g�����s��;	MX�ӆF
��l���Z~�z�G���m��(��;u���;����ŨԸ��G(Wv����r;�`���R�!�G\b�J�oI諪��� ?}p�      �   �  x����n�:�ӧ�/��=�+�r$ˇ�)��T�oƆR�EM�E!�|�e�2���u�y~���a�q7\�y�c�7������1�$k5�ҷ�	�D�K�_��~p�w���%:�Z��Ve6~�_��9E�V��s��#��q��B��4�k�����n�3���8�R��I��������CDf��)��䷒M���1BJ��zG�1�ivc<T�2�Ei�A�Q4�?ː�i�1�ܱc��Z�Z���["�~N~�ir�tr!���%L�?��tn��4�v�9l̓k�uP�� ��A?"I������F:���~D1Ll��l9wˍ�-ſo���c��2�u̡��yH?,�(f��h�,����_c
����D�&\n)L�� �1�r�����&?S��F������,-7����u����%�6�$`�(���)�R0�'��A���Z�Fp[�Hd���}Y�C�
�,�1�yU)����4ߘ��b�����H^7��F��џ]������dJa�SM
����eP��e3�M���Zс�� k�9�7����t��c��W�UIp�$t�8P��d3�.�Be�[�Z��� >e p�@�@����m|��{��O}�}�c�x����Nj�d:J!�j����:Pٮͭ$Ö�n�v��,d+y�DN{�B`.d��d� �9�{����D\.!���� �uZ� ��P�eƐ�����1'3-���J��d@u�L��ڮQ�-�1�R�<�ƣ�@�d�&7��2�릂r\���x�s@��0YU.��K�)�nO&B���u펵��p�	��%~�$H�L�3��`����[,C���C�W��3m��G9�?Ew��xG5��V
�y!VޟR~��uQd�Tk���5G��Tt��L@�Q?��Nb���*
X�H�pϡ���0���yV�z��f}F��}zz�
���      �   �  x�՚I��8��Ǖ���AREj&�r'��������웙f�6`�C��q␬�N�4zRd�9����'n���	�&����r���t`"��̸\�G�J����|w>�ep �zځ��ve�X�^q{Ļ��/־�pa��&]���Z�+L�UY�Ѯh�w���k�O��_]���C��yc�}j��%��]�;�ZoW����9�|fK�mxGR��K0avu���,�L���|1��-���c�x��2'���8� �A �?�/�D��MxL ��Qw_��lU�C���7������w2��x��'�����=$�P��L�T�쑴�Ӫ�/`\�?��/HEN!;�aȿ-52�'E�rF�w<.�� W�a�'#Eٷ�t<ٯ)�f�����#C(��su��U~#��gRc��vp$!�����6���������V6�owz���mF=���	ؾ����8*h�%A����Qse��*:}����~f�m�B��g��s���e�$������_<����+9�u^Vf����ʷ-|i��F(��>埁�7"ވX(�섃�
��Q�J�0��>�)Lp<TIT���*�"OJ����<����$f7�	���լr��8�-η:�Ln�*�K�1������pOw׸*�zkFNx4jR��C�,����꠬7}
4�/��<y`�=}�%R�\�l�����E`�����`�׹��Ɉ��8(Ĺ��o�z�-�|�T8���F�|w��m�*�A��NC�ȡ	���#�����BT[��,߉�8�W�*���h�i�y̯5pM�:����Ev�H�YL;Wk�Ŧ;�|{��"��"""�' �7#�oAp�<&���>�u�����<;'0�_F����=������c�ԢfSU ��/v�xw�s�	u�[��{)F?/�W&�3���)��8ɗ�|)\�;����|���JWMް�VI��zv{I]l�៲T�+ֿj�VY�����A�dD��߈�Z/�x�����ǲ$�R�f-wJa?�m_yS���јE��r"�L��(r
;d}��O!
�'V���C�+	���8��.�XG������"&l�W��<�z���P���yX;�!��E�LX�x�F�d|*p��)��,���5$<bw0�o������h��f���L���*K˵�RGU΀sg��W����8*Hd�gy ?�rv̠�q8Z��!q[���J|ei[%V�i͂ei��8��Y����u�RnX�\fy�����3B��0h�	K�g�ٽY���*��Z˪0q6�^�,__)��MD���$�������1j"]�v-���^�#2�9]�SFo�	"�OXY�&�8\	v0�`~�v�P������9�HHC"���l�R�����ýτfM�Zc�}'8������̻�D�3���8�?q=����� 6��j�0��E�����FD�a��|���t�v�q4V;�����&������NASfv8����B���rͳ�?�(qj�ϳ�ڼ��\��$�Ǯ�s����Eܽ`��ez4���E��VVI�Kl��G�mux��d?q͉P� X�1Z���3

�� ptE���K�7"���'^�|g�|p��A�ޤ�4�o����eo��*�]m���k, "�"�X~�� ���%E��~R�)uhT�^	���1���Ɖ�Ft���3�vz�p��GH��hK�x:~�}+j0�Ӏ��㭇��M�pF�G2�I�l�>e�/ۤ��V(�����%�1�~x��W�l���^����V��Tชr�?��(?�3٪<y���F�i�������t"}j�0��{g`�������ѵ��1k�S��?�X2�e?CVS�㱔Bv�h��^�f�t��9�g�T�0��<?.��Ch�b[n��x�ͪ����b��w���`q�I�V�x ���e(�dV74�7�O��f[R]���*���n��c�iO�j~�����x�����p�Oَ|Z9�|+�����V<�qz�W��x�{G{d�X)\�ϳ������聆Smf�a0�����\���������qG��qc�~32��Y���P�v}@�0���e12����OB�c�W��S��=�W�G���&{>���#�)���[Fc`�6�|�}f5�e���"��σ~0����5���l�Q/e�N���]+�����,;���C��UK��z�4f��͓_�+��7yj��Г�7�>�������̩�gǢ�c��q�f��]�X*����N�x�އv=��m��%��{���b����r����##����ȨoWq1�M{�Lq܍���%�LR���o~ �*1�$��KG<Â?��^d��{��� �nv^VV|��vL-F�3��J�Y��y���9�rɶ��4��*Փ��x!g���޲I�����e}dċ<�����P�{*x��r�I	PY���Ml|���V6Dg��7	L�M��������tۀn:��G�V!h��1z<±>������y�󹯓
���{Ulϲ�W���ڣ8Xg�&L�Z��JX]:C�2m�m�����:?/�,ׇ�?��4�>p�όH����Z.(�0�J���:/9���ԑ��T��u��.�����Ff��Kq,���2�ɽns~���b�Dv\C�D�,�}�� �-��t�&,�y����~��\`��d����2;+������y������w���9���S���3,)"?���2��	 �=�2H��]�E���S:%������_�5O�N��_]������[&��摗ә����Ėy6;v��A��G�}�!�Of��M�~��Qa�����WRbea���+u��V<�
˻�6�֢͗����nМյ���&]VE����"�ň�D�
)�y3�ǚ�[}2�¸w����Yq�J��iZ~'���(F�m]C�B.J��3�Kt��݂�,k�J����_���OF�M ���5��n\_�qN�P䨣F���~���72�	���8��C=I��]q����ru5̷[�XZ�l��|���-f��Q�Z���=�ތP�8}����u�D!JR�`�q�͗\��6w��m���O?��?ק]W-<%�d7��y�J�5�s�?z�|�!�����o��4�Zp��ƈ�}#��+u��ٽ�$/�c�ztW�~yo|�m@sdd�/���_^�����<����|�q��,s�.]�ZI4�ǣ6#�;V�~�\�/�T����ކ�%�1��t�<u�ẘ-�kju�<.�G���#ȍ�4�S��Zg��X���7����b�H��n�}��"�v43�-��F�������t
�|�m�+[��.B�~���鈾�F�0�k��\3���x��[lXfP%_U�V(��)��g�������x+{ھ���7�r��3�5t���E�$����<7�	���k���7zL��rг�@˺�P��FF���4�u���y�LI�n�ǩr����1��Ξ�<�y��\,-�#�"�c[����=���BzY_y���(.,�������w�"�Q�řԤ�̽_�Sy��s���1��S�k�Z���r��y���lĿ����YH	���1`C�����5*-���\��k��(?�C%�΂pZmp�{�| ��4����,.��v:S�=�[G�"��5'@>�#�]�z�E^����(�n�_ڳ�R�D�T�_=0���(��j'��!s��ІM
^�������ϓ#�~��s��>{��M����R];^      �   �   x�M�;n�0��>���=�Җ�k�f�ªJ�X��v�\�G���(� @�?P�亩��PR@�����v�L$��K����1����@@6����&�uZֿ����_��P����3o�8\&�Y��5/u�����y��|]X�*�8������M�4��@pQ�R+Ys���k��`�6Nw�nYۡ?}�IHXH-T���b��6�GK�z@����5ϲ�#\4      �   �   x�m��J1���)z��Gw����z�/�v֎M�d-��|_� �E���a~�a#}�7��W�����Io��C��q��뢁���UY	�2[�a|k=La�G�~��B�g�i.@�'=�Γc�󜼃�a)�%E|΄����I0��_��>���)�w�'�{�)0��K��a*X��_E��00g��)��[��o_�g���u�Ҵ���S����7<�d�      �   /   x�3�,H-*��,�4�2�L.M-*q��L�F\F��%51z\\\ ��,      �   �   x�m��m�0��d
���g�����S@��<����F0F�A��qn��j�8\dzO	�1��BY}�_M�ӆ����-Ϧ8ً�)\&{�r�����51<GM���wK�`������q�wϒ����������G�޽H��$�/�~�lB׽�'�ۓ��(ɓ�֓����JeV_@��Yuo�<�Gu����&��δ~.�Z�U��U�TFd|      �   �   x�u�M�0F��Sx�����'p�K7U�"BI)$�^(U��I�M�|y}� 82�\@c:u��u�FZ�9l���I<��QW�w��x�]R�ŀe`�� $�n�ʹ��
#����#F�0&�(NR�]E���]iæ.5ƻZ�C�MK�\�m�9���Ί��T�}u��c����-�����)�E�̷.o���OG��)$�� .�g�      �   >   x�Eɱ  ��Op'p�9�P)sh�{A�TȣB9~�L��L/z2������F� �`      �   �   x�]���0Fϟ�`���A�l��(DU$��$����H�@�����4;���=���,M��� MC�1��	r���	�q�rK���c	�W�}Q6T�EW?�b��O�3�$k|.����9q�}�h�.���ۏȺ&h_u~�O7�;"z�w8�      �   4   x�3�tMKM.�,��,�2�I,�J-I��9#R�΀��< #F��� U	�      �   D   x�3�J,�4�4��,�LJ-�L���4��9�K�9�8�9��S��9�<c(/�Jc���� ��X      �   $   x�3�4202�5 "#N�N#NNS 4����� O�      �   g   x�5˻� F���S0�����#����!���9��i�����pXWp�5v8b,�m	�3C�cC�I�)��s�aܛ�*h�w�j�S ���h�!p���Dt�7�      �      x�3�t���,�2�
u�1z\\\ .��      �   $  x�E�In�0E��)|�"�3.�NiW�e7�L�dɕ��mz�^�L"9����8���z��� "+�Q���`=�"[����F�KԊ}��e����䲵�j�Z[ûi�W֐�[rG�1��R�G^�,f���H�
V�������b2��$��-J�'��8�:���k�k���%��~M}V��+88�O�5�;w
�Sf��
d������Z38��CE;�I
��\��!��b���ⅻ/�|����[�3o�L⯠�g��Ě��Ӹ����χ,���c��      �   �	  x��YMs�8=ÿG��J�Q�1v��N%3�r��@,!�A:��M�s�a*{�����I����L\e+�׍�F�%dW�U�גF�S�&	�I|����$��9K{�%UM�T�Do8�S�=S+�9�F3��\o$���jWq�4�vWpQ��5]q�����Na\rE=t%�@�ҿO�c�r�+��R��e�eIٺa�Z^ּ���k�k�\��]�r�k���Ɋ6e�s�L�xF/�U5WT���_(+x��tO�oY7�הz��nv��/<�K�d�Sm�g�^l�R1���uS�G��c�5��u�K��)YK���=e˦\1,���UP�0?<����2g�@r���F�����T�{�����0A߱>g��T���R�����[V>2X���>��B��Rn������b�~I5��|�K�u�g�B�Ry�s�Wl���|#X�5ߌ卡�t�L(�6m�!�=k<+<�\hͿ��Ը��Fp�H���b+�k��әw%��
��ދ���=�a�ۡ���Z2��*���q�(�`|J~a[��f�#��7VM��O632Ŗ�HK�E|��)?,�U��:%e�Ma<��릪}��m�d��dB~��5��W��e)r�߅�D�h��W՞������1����8�D~�.с��Ko�F���=4����u��wbkh����Kue��RhP�o�i؂��E�����vFA6��_����<gf���ͺ*y�K����;�c{$������mQD�9)P�V<����(�r]�P��$�y�b[D~��{�h��^�v�Yf����{�]�<�_[)�B^Z�[�e��`J)f�^hg����ӟdǱx�Dc�F�����M�v;x��f%,#Z�"Yq�K�I+�����G�\5Kl'�n��8�0i��X���KQ��i����W�
f�EL��$�e �Z�v.¬8�i������y[]Z��7q���+[�2��mV���d�F�lv�4��i��a��ݎ2A�Ĩ�U+����{���tJ�=���lzb�Q�����@�#_G��V�@����_{ӳ,A�%#0�T�.YB�hw�������8��X~��w���-B�鄘MF���Ec�G�0�G`G��z��Iӡt,��MO��V��b�-�S����t1N3,X��(�8����
-�Xn�;�׺M��v��W)LF����;�8Vl�<� ���V�;x3�0�o��`�y�.�+ٜ�>:p�]d����i�n������r����ol�a��<_D����AmD�etL`�+�l�f�>p�d
��4T��C�Sr����qN���ҝ��/+�3�pF!�HV�å��Q��+���������H���{wA5�X�z�Ro�&���r]4K�Z+;�]C������^��5k���$�L�[�]6պ1��.�u�&N�]"J�j�*O�V���Qefas�,:��V���%��I�+�?�ǁbt�;�-���z0�<��z_{h�;��s�r�h�Y����@m��8��M*�c�z����f�ß�eM�Q�<�к�;{�p3}�g��f��j��:/�����v���,�iWW����6�X10���ׂ�؏-q.󻚉b�p�����r��g����^th�dw�Z�#�q-'�":Z�>#�����1��}��\U��;QmA��~'�{%e˷��Q:F���tYI�j^���?���ck7D�iO���k�j}I��&��~x��s�<��W�)�p%92�I�N����E��m�)b��6p���c�sǫ�A,�nO��}��e.j�Ň.6�r����ٟX��W�ܕа�8y����q��Q��ڴ�7?�Q�7��R�৘Z34Vs��K���1/�+�?9r�c#�]Bd�U53�'��nj���nG�.ͺ�G�u>�mO�S���|ĊT�,�v�=+��&N��2��;��ۣ�O[�ض|?��ڬKw�#�֧���(�e�ǈ���P�������jp*�^+�^<�٫U]��p����c�!���;�R:��g�q�m�I��ǆ�܊sY�����4��cE+�Ե0�~-HrDl�Ox�2��4�Q�m ʅ5T����Q�/�S�2�3׉���fa]�/bt�i��/=~���yJW��dB>��hߴ���N�B��E(��G�Y�Y�d��Oɡ8u�{��	���C$��Bi�_� *�y�j�Q<gw��ط����9� _����ׁص�ɂ���4��B�y0�'F��Q9z3]�(`OQZL��eQ�#Ӥ����).��L9߹n/��������8��'ѕ&$�!�@�E���y8��e�u{�7G�,��z��,��?BO{�rӧy�5(��6���,Y�i��V�.a���h���\A���f�������N�aS���0D�B�ӹ�N�,cN�ٸip01�b��Fy�=_���V���t.��^_�~��%9�-ۗR��l�"����/����{�qxV�g�������ی�      �   c  x�mW[r�:���z�������t����d��ݴp��O)�T����%w�q���Q������c���gZ�Z�^���*T�L�kž�����q���()5?ɶ玤�D�A��L�&NG���������ˠ��L0"Ϊj��u���EcKW���*몿���f	�"l�������ǰ������z�(��չ���(z	ɆVķaϺ2~F���� h_�cM��{H���QnX{4XP�1C�C�&�eЉ@©U���ĩ������L�J���~Cg�K��;i�귣�;AD��E�%����ۗ����P�5�
Sٞ�V]������{�l���G�Z�kh�GcP�]0ư�l#�=�<��e�(��á�/����E��5��k����}l���PYݏ�s�HOL%�5!.�1�f����2B��EY# ?��D�Y��� �O�~�,��|q��EY���±�NY���9�a>eL�Hd��|�ǯbf6�g��Rm�K �@�s2���+�(�1Cb>Pf�22�m���� ؈f���10h	Ĭ�@}C[`�lL4���p5�P&���66�q�Z6::lF'��l�S�a��D�!鄄qs4饤$}����m�4t�k��h'=�B(�������zdmȺ��N�
���	&�C�|b&�	�н�0P��������4ZQ���+��z ����A�$~S{.�Bh�U�c�u��Ӡu	&�����},-JB�n>�>�Uՠj x&� <���I�JdV&�� 6�>��W"�����-�y1'����-G��3u�
6���ힲC<u?u�qY����L5�Tc�n~�������L�hA�$��f
'TJ�����  �=>P�]���]������z���!�F�
�ω�`�. _	9q�q?����48	��R1"���4Q���B^����ƴ=�۬�[���%��~ �˨mA��1Y�iYV�={��陏X}IB��W㰡�5�C�k2�jہ��4ə���2�vH!�&B��(��9�CG��#.�m��]��U+��w��Ӹ�x��+ށ���bG)G�AtD�`nʛ���l�y�\7I"�ǣ�3������Q��W�z��~�����`�v@�eB�k��g�Y��Yyr�|3�D_���lG@���S��t�Kn?��}�x+N ��;��*B�+r��z������_;?%�n!*�W'����}u���W�z�q�1�o����J�	�O��b[d�%}-1jM���'��bk-�ZҤ�ud�Zy�Yϭ�.�vbaI읧¦��y9Ȟ�k����$��J.L�����E��'g�����}�Sk�?>�7��Щf�ճ�D�|�G��6�2�)��37G�e������Ӛc      �   =   x�3�,��LIL�,�4�2�����2���9Ca��\&�>�%E�`�)�ojJf�B$F��� ��      �      x��]o�Ȳ��=�B��� �D��싌��gvf���`ĎM,�H*-!��t7?TMR%�1i��Z�eIM������������tf�9[0���/Z��9g�o��K��}���i�[&����9�oX6s?�����#3L抿�G�I��Z�4�����/�@��Ȭ�G_��?����������i��������凫O�[��1��͘{�����9�X��ՙ��}w%^�|cn��_�lޱ9��	��o�?���ᑴ?:��qi�7s��^��������5K���Ls����>]:s�Ϳw�?�Ec���e��*��9�<��w&>7j���#�6-��Kcf���Kv�Ee~�|���7|��o��m�o~��L�݄Lm���}gA���i�>��o[��$�����d�k���o�}r���Φ����)�Vc��X{��W���`��ێ����ggG��忣�g�=}��[�M�Ë��#,�Fޒe�-k�ɏ�k���m.n`�����3xy�x}�r���Q��OӃ��ȓwc���_��߹�4��0nN�ø]�qsr4�/�$%=&���a�m�#s۪No�r����-S���̙��J��-�̗���a~���>�g����#�A� ȷ�d���[�V�g���K& ŐbH1�x+�r�ER��R�HPC)�"%�Q%����X)�{� s���;�L]�����q}�2Y��m3N-�Z.{�8b��x��y����^��\D��{3w����<�.d/&�
=���Ʋ-.��g��`h04|r<*����$����`.�_�/����!��"�;:j�Ͳ1�� C�!�`*�����c=�#��ڎ�Bn%Fj,�Ħ���ʝ�@u��`)�������Tk�'�~�ޟo��˿P�B|��������C���'�	�W���(ޘz�eɧ1L��(�l��}t?�A+�~UF�x����qҢ���f�od��(��6��M�o���JFґ{�%1X��-Ob�Ж��i��� ���& |oy>�� ����96�37�Y~<���_9�	� ��%0�@V� ]����@X!�y�����   ��	5�Z�$��]�ӁA0�bPW� $��?�  �G x�s���\�{��~�@�B��\�gf�.����.�p��7�y�����5��8|�s��R"��~gV�PS5&7��w&�ј��DP��R����P��^ܶ7��6'�x �T��\���MP�@]���:9�)��4�x����ϓ��܁�R��t���ۗ���R�S�[�u�-�(d�X�!�$��hΔ��$8g�,���,Ҕ�ƞ�T��(���[�ѵg��ZG��Y](�I+D1K��[h2@�J��.+a�  � ��W����(���@(eUPF�NaU� Y��)u�R�}��P��6�3�@�Q=������3�M��f!N#��g�V
܀[���]'J�Z(	��p����w�4���f�;����*��Fw���_�A|�y����_O�q �5	0%� ` �T����X��/�U._ʾ�	�` �R���i��` �ح��w��������c*�c�G�"��l Ãv/j%w�}B��:�J�>�]��j��y
<�e*���W�\�����n�+�С��c�1���z<g�qX�<��n$��Ar��,�۫�W��C��T�C���'��w��ɚ#wrL�|��aV!	��6o+�s��G~(,�T��k�?�l�����U�^���ͨ`��Rق�G�Ǖ=_�	� ��g�F��K��k'���i��ާ��
��GE�.{�,]�ޫ�]��Gkn��&ç�#��:?��F}�wR�&��|
d�އethϷݫ]���Q!����!�թo@�G��l[�;���~��6_|�^wZ�/�ҮaB�!H+޴K��W�c�+����&x�0g�N-�<AXkd�HϩNZv�W3����n<��o�ݤ���xO8xutz�f+�SMV��ә�Ī��u�b%+�09��C�C���;��?^6F�#�lY�V��2�����h�>7lӛK�C?�����>Xv�$-�2�4ܤ�/ e�#_�1�������|����[�[���
��G�������ۿ�|{���rf�<���˕�'����z����-��pZ�����l�N9;ӻz�UW��[��B�]�_�M�6�����r�j�I'�ީN�	�i�3� �x3����<m����o���}��궰?�E��8+� ���
��Wp���dp����[f��V{�B�oμ@1��R)NH�e����8��euE����x��ƽ�!�.��b�CXo��q}�~�/_V�k͜��ZK�1W3��Z.{�/���fv��[��-��6��6�i###�\�Vd{8�����<N@���_����ɓz� Ww� j5�C�OB��Nu$��N��I\d�����6߸uV��(���!6=ǝ�vo�5��^x{�]U-�GG�y��W0|�'?��_u���i��Uw{�.[2���x���XS��jX/�=8�tF13����������*�,� ��U��	�92o��td���^��
��� ?��M2��[��\k9��=�CpX�t.:IYAF}�=���f�NA��[o}g�o��^�hR���S���ha�	��_����m� ��*�˫&5����=��
�'N�G ���p�5��l@���� {����?�.c.F��?��hZN�����,�O��G���=!�om�6��y!*S]�T�T�8�>��Ȭ#g�II	� �~��b5�U	�  {`��xr|�/��4��_�"�Ʃ�Y�|������C���W�|���_ǔ_� L=e(��{7�ğ��'����Ө�M��A �'_�:gR�w�3޵�1��s;RI�7���Ű����ޘ��C�r@ȕ�:M��	'N��g�n��hܨ;'����x�thm���)�xNO'%m����I�G����[ٖi��f���:P�J�.��|{��n����3��ĥ2%*˽�J���ݣ���aw�j55���< ��l�wp8��� ��_q8|��r�R�+��_��-��C�����S�/��J�k����|�Ѷ�>�$�@yX����F5{��]��^-�2�xm�� Uq�ߊ���XyP��VŽ��N�D��c����0Ir�S�_�y��X)�3���8�����p]c��g�H�� ��8���j>�%x)�
Q,u��{t~\���'ޛ�B}��at���4.��z��۞־��|��;� ��Y�����i�^��/$��W2��UF�� ��,� ���Gkn��&&�2\�G�Ӑ�=��M���_=���1|�u����j3z?Q�?�8X�����T���\[��K�[�OiF�G}�w%ҿ�}4$�gq���v��z��l�z���<o1��J,<�]g)#r��Ӵw��0�R�M��L����>Z��>ₘ���7��F�����͌��'�� ���}��p2OZ��<i�I�+��˶G>�f�� �G����o�Z�rn���G.5�%��p�o~��ֻۿ�|{���r��.�6i�\�|J3[߮|�)^n��!|���g��>JggzW��꯴qK_h�]��6>ۈ�.���(^�^'éޱN���&�SG�N}��Թ�^_�|���N[�7Wo���|u[ص��u�A�q�8x��9O��]��H��Yr�j�Ǚr<�%���+�q��pHo�0̷l�>k=Z���˪���s���2Y+�u-�=�]>��Z�n�y�㿳�Q؊<����~###r�FD�aQ@���,�Οҿ.�Ӟ�C���_�oV0Z,��=���:�Y��e���[g���go��z?w����t�ޭ�k²�z�8�T���/*_��9D��l2@|��R�mZV���%�l��}t_�{x������\�03kQ��щ�$#T�J��
(����Ʈ��5�~��d��J� ���( #��    ���*8�s�dj��m�<�Wxt��oG5�=��
�'b�"��K&tw��2�+Hݕ�U`�w&��wQg�����f8�J�97�s2%;�BT��}��I��q&}��R�#g�9�
� �~�h����0 �4�h"=$�_�\�h����WA��S�y��p��H�ͯ��hJ[��8@J�#B�o�=�����G%��[�x�Ӭ�)oM{C�� 9 �J@���K�/Q�ԁ�*����ԡ�+pnŜ<(�z<�p� �Z`|LYWD� 0 V*`jYWD� 0 V.`(�
��ׯ)�
���*�Hٛn4y��7����lW�J��]Hw�~�qR�A�J� ��{��p�g��S�(��(��"��`h04EQDEQDEk��FQD]�_]���e\�
��3֖4��\VI9M��UPR�W�Д�Azђr�W�oޠ��X�b�{�}�If1�]j�?@�o��.Z�MT���w�w�C�!�����J\JmϱvHw���Q�,=,�i���Y,]����?�l^�P<���`)`)`)�i�>֋h�8K��/�d&k@x 
�?�g:�
�g�P�����B{���^h�N�-�(чY�;�3�}4<?3!
���+�,8�
�����CGp�|��_�'�Q��G�խW"%+��a\'S���%��}q��1/�jh^��O�X��n��`,V�b��.�;0�q� �U1���I߉Sd�������6p����b�b��@V��$�~v�̝e���_)��0;��4>�   �@����W�0q �`%�96�o�}��UE_��M�wiؾHe� �A�M�Z�v��� �� ��E`�ޮ��p�A x�w?�<���074��
�X(B՘�!b�����E�r�dlo�Ղ�AY�D�����:��bio�x�����;����Γ%���������n��Kk v�ؕ�ݘ�4v�(��<�W������TSF u�ԕJ]��e{c��� ��R��%���NzmA�u�RGk��]P;�;`W*v4N'�ZG�J.�z hؖfGc6̱n���R0�G�0f�`�Y
̀0+3��k̀�a��e��ă��ױ�xP�\uh��o��uԈ�U��B��B<�A�7��3@� ��!��U���g��|Uj��Ғ֑/1@�8��r�2@�J�,��+ d����R�2@�J�,/Mh{c;��.�e��38?��� �I��c�ڛ�-�֒��k���=C��m& p ��=>���QD�O�܀[)�奷no�0�'�p n_��'�_�ȼ�p�����)���u�A(��,H���_�T�&tC|�/�U*_z�BO��j_��E��/��$��R9�/����W^�	�_��i|Q��	��_�R��0�/����׉'�_�J���x��)�������~������~f"�o�B��G7x\��0��?:��X�R[ejL$��x��g6�a2�{��HN�2�I}�q˛9��A[8p��`�m��Q[�5��j�Q�-��l�X��i0ɷ�IN
�)[vv���h��kJ�:���8��ա7'Gc�Bj@V����e��=2��?Z��+� �;�C��(���:9�o�����A��X��*pX%��s�`��U���:
9�C�!ǹr<e�qpR(Vc=R��Ar��,�۫�W��C��P�C���'��w��y��d �B.m>�ŧ܊W�/�3g�Z��(O�!�\"(�On�%�H����|�K��O�K}�y��L�[,��8�����p]c��g�Ȁ��ocڢګ�\����Qԓ���x�Ώ+{���{~A(�>���\/�1��g$���i���H�g�b������;z��q!a���t�M�ΐ\���h�о��l%�ǡ]���π�}D���0s�񉂬�gb�t�f�}0&}���o��Y��6_|���J�����Z,W�Ϝ�����C:?��V�o:���fC(���Ȭ��x�t<H�ؐ�+��0]^CF9��Aⱆt��(�S��~�����y�Bhݍј��G�Kc�z?�*���i�u� �V��P;���h�~�:K�7����\��s܅!�o��2���k���=�+en$������q-��F�ě��͌�|��?Y}��p,�.Ѓ�>n��"���&�p��m���ۿyky˹!|ࡿ2prH7y����8[w�7�o�_�̘��4_�\�o׋��x��m1���&|���g���L��W]��6ni��w�w_u��6�مN�����ަN������0��x�����͛�Zo���on/�>���',#a�� v�3p�;��r�Ej��R�D����ƃ�����f<VJ�޽b�����N~4�_�N�"`�� � � W��O�3xo��"�zD�@�!�a�p]DX:�"�'������H������ʝ�@y-��#3,e\�p��:iU�5��^x{b'���\�܊T�P�C����&��W](S�0e�v��%3����������iz���;z���V�S�s�G�o���J��l�8�S��'��#Ҵ|2���X ?����O����^��f ���	�&MbV���3Se,s�s1D�����hZN�h���g�?3�{��ϯ����	v�3/DbrW�3�����<��9)�)!�k*ۀ6��\�h��,�7�V0�Wp��Xéjv�+��Zz'��RQ�T���������͂�r:��B���A�Ѵ�����7��܀p�7���G��DK��	1I��#LR1I�%�M�0j�{|����E`#� ����z�S�ٕ�$+�w��rT^@�o�[�������[Q�H��(K�Qyr9�C�K��"g��,5����7l�>k�c�_����o=ך9-����Y�e,9�)~j�'�k�ٹ+Z(6��~.�ֲ[�������Q+��"4>Vk�~J������ҖЮ7���Ns07���Nbx$�Hm�Go�N�aȐښ��=���RM�AB��h��b��#f���8s�p���L��gL�>����x݇@d�P��"��VE
�nf�� ��n�������TdP��������m������#�X0�Ȃq�Ӯ��ͲK���mX����D�\���^� kd2��Ěq���R�B�"QJM�"��qo�c���-��]��\,ۘ�r�Օ���n�y�㿳��aD`D`D`Dv����l��u{��`0��)<�*�8S��y� �a�1�j\5VJ�����BQ����D��"Q�h��W�(x�95��t4E���5��)�_8���D�N��41����k��6�H8�")O��HlP_3T���S��v��z>9��.� �|������Y�5��t��?��k�I�F��|l��.�|��
�������쁽J��+�%��[7A��`�i��a����&�{`�W��Ք���dtÊn�M��{�`�s��t��=3�-A�L)��f�@�����K6�[f=+t=S��xGO�����&J-y��q�#n�ٽk��̂}���[)�����Ln� 7��J��|MO(���ih`�]9��x��vH{��pn���:�b#��:��;���������'�q�m�A�e��J嫗w@|�/��4��N`�/����W^\�_��i|�}�/����W�!	������~�ϋ8	yʫ;B�XԈ=L.���ʃl����Q�5Z\�y5�U?�:�|��Q�G+�6��m���]�-�Է�i�V��5��fotή]�Ӳ�&M�ր�S�5�f�j@ϩ��)���^�n�$_KS�V��Lfqʋ��R��OmUTQ�ޝ�f��q�<G3�m]g}��q��E�Gw��5Q�Y?����er
��z��G�'�W<���?��������끯�����ߙ�oߥƃ9Fy罂���d29���e)rF-���"�"}�g�"Z���d-�I����D�SF�#R�w%�L�[���&����ǛT����`d�|�f�e/��
"LR    ��N�A��~)|J-��|c[�����ث�J����9��'�z�=��K@���	�@ȫ��I��[����<�W	y4)���K��{`��h®dT�5�������?�W~�!�d�k1�pQs��	<�����6������Տa� RW#u5�����DY���xoeDI8C� 7��J/��a�\�?�L�6�V~��t1Kf&`l���l����A�/���O����uc��7��J����oo�̃ml�����m|N�v#�:@Wv�X�%PU�ؼB�u��>���Ic\p�z<S� ��'֣�+`���*�/p	� Xɀ� Ke_�\�h@%�_�\�����7 ` �I���1�����z_4N2���  �Xv�syoc��!O���+i��������z�^�&�#�{����t����_憉l�%N����v��\k�L֊��ª���fv��[��-���LU*��#�j�l��cP;��j�(ż�d{�g�v�g�S�ۛD%���5�C��ƹj<*���A��r�����0� ��q� ����p�Se�tXT���W��,�j�����	�C�OD��"��iU��v�8��:L���/ؼY|����r��Y.����p]c��g�H�� ��8���j>��s)�
Q,�z�{t~\���'ޛ�B}��ᡰ�E�MIv}�����O;9�i�e����{���q�h�M��d��{�*\�G���������A�3���tݎ+����ծ�c�q#.ـ�O�@K�տ�҅u�����?��(yaq��m�鳨0N�MU\�i�(��n��j{��H����Mz��2��|���z]�S*��f+׫�������Vb]$jx����$o�,��.��y�?�3�xa5����ee[�Wu!~����F�<���͌�|���B}��p,;\k��`�An��푯�������<�ۿyky˹��vX���t��o~W��}�z{���r��3�86i�\�|�8[߮|a,^n�a$�"�c��<g�ggzW����_U^����x�i�W��o���x��>�n�����7�w����n��I���L��n>O[o����Ϳ>\~��mv;���Yc�|��	Χq>�� �e������|NA.Z�M49��A� C���ܳ��P��`\~���A����9A�s��㵜o.�Y�C��Ļ#�������H�{������`	���B����[$�}����IU����
C�!�c�q}�X�^Gj��N�x;��ڬ��96߸uV�";+��"vA���p�=��^x�m^U.�GGy���W0~Q�'?��'_u�r����@�\�˖���G�5���*�ͥ�F��e�?{��#��7��
�-��>zB_S��i�4%M���6�?�W~��ʯŖ�|��
������7�|�{`�ƞ��@��p��^*�O5|Md�ߙ�'�e��H1|�g��M˩����~f�����_�*u�S�]���������㬹Z�=���#g�I�� �a��Q3����ّ�|���|�e�V[o+Tm����XOj��P�Cu�W��7�~�F��eC]6;���8��e��t)�?�xo��F=���e{��'pn�m�r��|*\+�3�>�X�hi��ׂ��Q� �U6/�k��
��"�_���Vw�3���U�����jU�P���\ �@}��P�	U���k�~�//�P^������I�+hD�)��pjX�)��pjR)$�2���������8����C����,Zk�uR�G���tR�aDFbװ�I���0y�abS���]������d���z�@L��1Z��U�䗄'b�o��5������^������.������l�G:ZH�(r{�br`�,T*�
���0��ea�.Wf:�^�2`Ì����TSf�r0�_�/����`��,����z0Pc�1�j���GՃ	|(�W#�qR$
�;�
�O%ajPf�0���/�k��6�F@�n��m�)�@�+(�K�����na�u�̬ �	 D�X6����������h�
A!(��X�
/�ݞaN
a%*��9�[�e���KA!(�UPHW�IS��i`���q������J��?oBj����7�j�\�>:|��ǎ}�*E�RHL�����5�ͽ���ԁ:PWzB���Kɱa���+��9g��,��<��JOF�1�4�c9 �JAn�k�P���"�շ�K��:�\������1>��Kr�
�  {`:�_��E�_�\��L +���|��|�[6	yʫ[6��b��eǃ��7�oE��y�9oP���}�+�P�����m�#z��\֣��a��z=���GV�Ԯ���b��A����t��KGQ7�"�Yţ6�h9�8��!}�%�P�T��S��u�w�;(.W��rd>�,/�\��?���>�����jT��R����LM�-/����oN���0\>�W\������̪F��x���I�-3�E����ܞt�9�����bhq^}9m�93.Tan�+�6:�❲U8,Tc�d��b�F���M��R�f��(�[[[�L�vmT���6����0�y&�G jA�!�Ẋp�"̺�%��E�3�j@~!��_�/�7��"�<�~����'ڛG��́!�a�0D8�~�>q�֋��ҝ2Wx~�N�s�;e��r'��0L�fA�NT�x��5/�*K^���l�	�!0��N`n��˹Ff���*����Y�;q��=�W	{4eK������L<A諄>j��g�>��<�� �z^�V��gFq =���\���J��J�`�U�^���$ػvs5�6�}�L:�t�=����6A�yU�=��}���3l�2��@_���w����9'�{��Gw���v�Շ�􁾃��;#�D�uʞ��NT�����5�b�>�3�uѴ�*<ۛ ����O��i��ǵA^�N{G��)S�5J^r�f���?�T����H�ׇ'2�B�:�w5�nBW��8��fD�ג��s��;p�k�R{��k�R0����5�Q*݂����/|�\����xy�����:@W.tyq���-v�ؕ�]�!��&(����+ׯBx�xp�V�`l����2���#l�;�cg�f��&]2䭎�����¦7̨6��X���yX6�؎��.7%L[��*H[4W���M͗����@Tj��"�'j� ��	]_�"��Y�^Sª]T敀` �=�ݏ ` ��=t�[��U��0#� Y� ��R� 2@ȞY��;�1���,������k��s�؎�6�yc����wkI�s�6�ގ7n4�#!����T� ��2����}[������Rp����}�� ��}a�wr�8�х��{�W��
�><bY�f�	�O��Z`\�CO5!X|��&�5��!N����	��` �=��` �Uh�:͊S_�I|�� |�/�/:9��_��I|����	ɘ��j_ژN� ` �T�4#V�S�/��$��3��_��E��_�|���g&b�w~e�N�����G�����-C���?�J��Ǆ�w���E��@�Y�_T���*p�s��&�	�-o��m��Q����E#Gm�GN�\�X���]�p���b鯧�P$ߺ'�6t�l��=��������A7'�aܮŸ99�R����.3L�1���2]!/�%�I���2� /�����}lP�Q?K��n��7߄�{햿�<`|B'����c�1�8s�Iy�G�#��I��G
q�κ�i���[g��X �.�V���≷K�6���79��c/#�Y��^�O~py��` "O~:� ��B����F�-��O��C�=�]�8��p:���xcS�~'��� �.�rp �U�� p �	�(\�#&���==�LLk��s��]�9%!��|�D� �  �B.�g�������{57L��"3�'�Kh�)�5߾�53�T��/;Ni�J��ENm��]�	��� ɷ��a]�;=�~$pZzFn���p n�ʁ�����.�(ߝޥ�}�*ƪ$�l:��� a ���)�.A�(`Z����p�m<�~@�������OŃ��J��!F1z������0R.��Q/��A1�Kӽ�Z|en=��3=�C�!�'"�w�؅�Ry{b���]|ʭx��"H�˓�`>� t�і�#i[������/�?e.a��k��K3�o]���#_�����p]c��g�Ȃ��ocڢګ�\F�ӫQԓ��[�G�Ǖ=_�	� ^�y~���"f��-��mOk��ސt�;�G�-{�,ݎ�K��?�/_�Mg&<������������0sm��w�AF+�M| :��U�!�� ~%�%�T��U�T[�2�j[T�l���N�Gkn�̦Z8"��u~4jHMH��E���_-��<b�=R��6铞��،oHׇc�uy��v�4�)���돯��_iC�GzOԤ7�O�.�˚(̾^S�+5�!�����dD�`3:���"(>ߌ����&��cjE��PC:N�0��պ�wd�+���3F�nG�15��W�FuB���M�]��5<^^�5�����԰��5u��k���_>Iǩ#DY׺�D�u�uo5[��z�k7^�0�\��R8^�/x#h�waH/��y'p���Ϩ�=��F>���7��_#����͌ep�'ؐS߾0�˦Π�88������{�C�n���G!���o�Z�rn�����R��#|{�{\׽���̷���/gf��I����*9[߮_�����c��Y�<;ӻz�U��Js8.4��?�C��nW{�����~���g��      �      x��_s�6և��O��zfo�.����^d[wۙm���}/6�H��fe�#�I��|��  %��e9�)9v�J 	 ��A����e͞y��3��~f<�(��ei��|r{�����_��lz���?��>}����C����?=:8���C5��`�'���c���[�'a�aF��|������]�F·?8���WA���L!�W�/���я�G�>��g!;��acm�S_����O'[��0|�M�����U�������&�����d|}~��_�'���b_��ƨ
��
��Of����r��Ї͡�~Ǔ�������9�l��[Cr=N\��;�m���uNUH	Ɵ]�j0:��<�B�<S��Me/�}1�k0���׳��?�WKi�����c<��/��+���d�))�,��0K���&��엺������W���E����{{3}��}tf/�K{��peg�v�6+�������[�<7�ƣ,��^��xX{FHY�2H[�h1�վ��p�a����J�Au��w�[�y�����^פ7�GYJZ��Xw9�|c�Ǵ��u�yr���]W�'��q�a�!a˲O.n�H�=s��q����nz������ut%�T��חs��m�^ٕ��t��_�߷�~|z�^�Qc�F�YO�ϼ�ϏNn����dj��e5�P����/�8zY��T����ڈ1m���Z\���^Ѱ9����WƆ���͡jmhx�Ɠ�?r��$���ğ 0���ÍCE�u���������+0V`�X��jm֫�Y���[��o�[ߥ��aaa��",7a�V�0[+�v?z�(�(�(�(��*�z���w����텝�,��Q�Q�Q�Q��"l��b���1��u�ΈqTfgg�l|=�|R�4 �7"�(�<�u�)9��9	X;m*��gq��V��G�4Ҿ�x%�y�|vˬ��y��Z�ĥ�h��B.Ŵf%��+og?��:w�has�syB��DbՏ�Y,�q\]���+�i�%���g�u�QCϖC�Լ�/����;��ˢ�5���o�__R�#�P"��AIM��8�q��p|aD��è�ӻ��?���"�H"��$�5$����K{�]TdY|�����1D��c����#���ʙ!"�� nD�׀x:�Y�=S$I�=�Bf$��/'cw]�dY|��i����_&�9r�!r��>&O{t��h6pYD��ݳ(隐�r��N�D$�H��a����u9��SdY�L�|\�f�7�g�w&�Sɻ����v<���?VoIW��&~:m\��vt}�'���@�4�<�����T��@tr;�]���Lk�A�������jjΦ����(�����wD�+	�H!R�w��
xiv��m���%��_�)D
��*��˽�:Ll�K1"�_�zi����~6vc8�9�JEDq�׆�*����!�� "�K��f?���cB�!�%���<��q.;R�"����/����Mߘ��!z����B������{M##uH�^S����x�H<D�+A�X�C����|� �z�����Y_gry�=b�W��?ajyH����u#��E�+�C�r�r񈑺���o4P#r��#"g��ҥy��ݖGb�7��1/F׽�qC��m��;�↸���q�o�&"��=�L�p�"w�ȱuK� r�"�m�D>jҟ�}r;_��oe-�M�;.�=Do;̼������(�k���}����!}�
|�4��ܵ�۪YV�C����'��˱�*�$��!|����&,Ǿi�x8��!~���&z���}�B���χϳ�y�=��T�C�P�ԛ���O?¤j��:$�LΠF�-��-Y��!`����C�v��ּh��:$�>}���B����5F��|}_"�8����/����E�A�0�*`2_����D���C�+�ǌ��B���W>@���B�6���Ǖ�uG�e�#'���ۖ0��RT��x��^�ܝy���Sx��|��Y�������R;�<�����b��`Jk<���<���zN7u�9m�Ţ����_����˫��ir�������mݹ���[�K��ϓ�N8O���<����7�7,9�nDrz5��M/�������d����NDwK��m��E75~�f���X�U
L�Z	>���������땏"C�_����������#ȭ��(��7�̢N;;�g��I�O��N�7d��m���JN������g��"�|>� `Ɂ"��:+�`^썞od+b�4N����������=2�/M��,:�����wOM>q�g�#p�c��Y��}"p�u�-;���tݗ;��nm���K��Z^���[?�Y�+pm4�E$e�D��__����ٿ��,Z�.�Y4Ғ�������K���d��4d��t�چ��ێ,KKW 6���+�ą����}!���[��.ߠ��w	_0("~����{��x�����?��?���x��\o�������H��m�0�w9�0$lGS�cP�&�-f����{uz�篧�m>���A���p6�7$=8������.�R��9u�kފ0���+����������Y�?�#aa�oD��D/��g�#7s��$���XV���sf�mTϐb'{���_�:�ZuYWG��a�����a�/M��^���>���4'h����=>��$����/,�{۹ʌL�inw����������ׯ�ݸ
�gc���࿧�5�'�����nB���MG�1�q�;8�w�$����־����^)�Mk�t�H��&J��`�&~���u�,����r)��>o���}{�V������R�a85"����1]���1��pgSA�e��ۯ�����Ϭ���0*_�q�rO�>��5�@��!M�0�D爦(x��Bf������:�m'�0ܼȣh�	���ݵ�6�M��H�����Gi���xP曼��[L�
�h\�Ǒ�����(Fso:�+(F���hn�_>3��8�v��t���է���dڭ���0
G��@���Y��<�[!��"ۻ���ԭ���X>蜧�Y�i����zn�&8n;B�r2�
}�6��4�\ژ���;��Jh~��)����\�o��aH��'2�#7��Uz(ݞ�~i'�Q^Ҕ�4%�Z>*+��l��F���vB�&�}~L���&��x�'yK��Gsx�>;<Y�������Se�?\O ZV7g7��W�|r����v 82��kJ���e�F:��0|�|L��
E
`m6����Mۢ�j���>��ԭm�8v[�z]�����ԁ�2E�i�1��d����LJ"�P�q�<��r�'��Z1e�{�+VK��&J2���J+Il�����k��t,��A������3le���#��q�h�s�=�a�s[�*ۄRFU!͂}���9�s�d��b~�����t����T9�V��8ȴ��YN()���$�L)d!��\�V�<�^�0O��`[!�����:�C�p�Q���%))sڔ^���+��&�Q��%�r�T���
ǘ�c�-t0�;�W%4��`�$�(h]3S@-��RmVRq��R������0[�
̇=�1���PZ�	TNQ֌`���X�JB�)��A�T�@����XmT�-	Qe�KQp����RVk]Ji�|�A�s%�*��]IG�4ޗP��օ�*����Y��Q�%�1%�be�d�#$�>�j�iM�Bk�d8-*b���9�`���f��J����)�k�w����1fxU��B���T��ڗ�s!��j��ҁ��VJ^�*��,g�$���Z�[<VR	lCAJ�y^Prb�t%8}�3������4��-�ҙ���ՊSNJ��.R�gY��I�(5�2�]C�W%�\�T�Dm��,	Vp�����7�*����%�g1FKC=�p�(�I(/ap�� de)pߚ��
*HY��V���(���(�`O�J�G�.mhUJ0�I��*Ym$ �
C�S���KE)ÿ��%uJhQ��    P��DA��3�x]VJ9ù���YC�=x\���`��� ����w����&�� �j�m��kZ�`(<��5����U ���,�%�@�D�,%��!5�d�ZYyYC]
�
'Jkg�8p;��jF�:(2>V����&�C2�I�r]�)�T�!à�%hbTTY��I�Vw�\�c
 	g3�
ۊxI���m��7���[�m�N��������@��=ڴ���A��<�*������ �Y���M)�I�M�������Ag�{�a�ھ�̅���Z�\��u�&�@,�eH�=�h�MI�rɳ�}���y=�g*����~mS��d?��������+˨זQh{����)i��h���x(1��B؂=T+�G1�_ȩ���G���53��Dolq�8E셄�
�pz��N�1�*|�7䰲l�e�}���P��~�kA�O&�pT�"���׈ԣ�p
�v?VUj�6_�W&�쒏@.����N��R�S��lJ�L��W�cJ�%0j�,�K}��1���h���w��k6گH�v�~��n��	e٠��6�/x���bd���H���D��G�4}v��H]��1�5#-mbC�
Wp�E�R~�5��0+��O(�9����g�?c�#υ����ނ�ψ��=�� t�D��YJ�Ag�xV@��Y�Q�.�'���C�z���V�t����2�i���Y;���hzo]���K^������G?�����?^��N��VrWǟ5���\q�+Ns=�i��?�%��r���58��??:�mG�6��+Tc|� ��������Z-�ze��·os-.xG�c�h؜���C�+c�]�tC[���W�j<��#�ҝ���? `��g���/v;��X��cŗzFXo�&�W�����xk{?޻��P�Q�Q�Q���E���a�V��~�Q~Q~Q~Q~�U~�&��-���'Nn�N������y��}c��j���ѕ�M½׎��{G���_;ʞ�}�h���Þm9�׎ʥ���ì�[{���G�,���/��ok�~bl���.b+.ѻ����_���y���w<={�����9��D(Jj:w�y���d!�#¸[U��~��v�7$IDwLb�F�>��~��Y�YD��ݲ����U���߈!b���|���h�1CDq� �����t�"��$"�;%QȌD�#��d�+���,"���=-�{����?G9D������E�;1{I��,"�;eQ毤�ė� �H"��[�{��x��FYD��Od1��+�o&�/��LN��w��k�0x�������N;o�8�Mo���Js�3:��N�	D'��ٵ� ˴��ج}��/>����l�9[����p�{G����"�{G�ɯ��f���6���K���R�~	
U�{��T{� �B��k�P/�2ҁ0{[��("���6\7U��vp�D�]"�n6��m��"��.!\����mz+2R�"����/����Mߘ��!z����B������{M##uH�^S����x�H<D�+A�X�C����|� �z�����Y_gry�=b�W��?ajyH����u#��E�+�C�r�r񈑺���o4P#r��#"g��ҥy��ݖGb�7��1/F׽�qC��m��;�↸���q�o�&"��=�L�p�"w�ȱuK� r�"�m�D>jҟ�}r;_��oe-�M�;.�=Do;̼������(�k���}����!}�
|�4��ܵ�۪YV�C����'��˱�*�$��!|����&,Ǿi�x8��!~���&z���}�B���χϳ�y�=��T�C�P�ԛ���O?¤j��:$�LΠF�-��-Y��!`����C�v��ּh��:$�>}���B����5F��|}_"�8����/����E�A�0�*`2_����D���C�+�ǌ��B���W>@���B�6���Ǖ�uG�e�#'���ۖ0��RT��x��^�ܝy���Sx��|��Y�������R;�<�����b��`Jk<���<���zN7u�9m�Ţ����_����˫��ir�������mݹ���[�K��ϓ�N8O���<����7�7,9�nDrz5��M/�������d����NDwK��m��E75~�f���X�U
L�Z	>���������땏"C�_����������#ȭ��(��7�̢N;;�g��I�O��N�7d��m���JN������g��"�|>� `Ɂ"��:+�`^썞od+b�4N����������=2�/M��,:�����wOM>q�g�#p�c��Y��}"p�u�-;���tݗ;��nm���K��Z^���[?�Y�+pm4�E$e�D��__����ٿ��,Z�.�Y4Ғ�������K���d��4d��t�چ��ێ,KKW 6���+�ą����}!���[��.ߠ��w	_0("~����{��x�����?��?���x��\o�������H��m�0�w9�0$lGS�cP�&�-f����{uz�篧�m>���A���p6�7$=8������.�R��9u�kފ0���+����������Y�?�#aa�oD��D/��g�#7s��$���XV���sf�mTϐb'{���_�:�ZuYWG��a�����a�/M��^���>���4'h����=>��$����/,�{۹ʌL�inw����������ׯ�ݸ
�gc���࿧�5�'�����nB���MG�1�q�;8�w�$����־����^)�Mk�t�H��&J��`�&~���u�,����r)��>o���}{�V������R�a85"����1]���1��pgSA�e��ۯ�����Ϭ���0*_�q�rO�>��5�@��!M�0�D爦(x��Bf������:�m'�0ܼȣh�	���ݵ�6�M��H�����Gi���xP曼��[L�
�h\�Ǒ�����(Fso:�+(F���hn�_>3��8�v��t���է���dڭ���0
G��@���Y��<�[!��"ۻ���ԭ���X>蜧�Y�i����zn�&8n;B�r2�
}�6��4�\ژ���;��Jh~��)����\�o��aH��'2�#7��Uz(ݞ�~i'�Q^Ҕ�4%�Z>*+��l��F���vB�&�}~L���&��x�'yK��Gsx�>;<Y�������Se�?\O ZV7g7��W�|r����v 82��kJ���e�F:��0|�|L��
E
`m6����Mۢ�j���>��ԭm�8v[�z]�����ԁ�2E�i�1��d����LJ"�P�q�<��r�'��Z1e�{�+VK��&J2���J+Il�����k��t,��A������3le���#��q�h�s�=�a�s[�*ۄRFU!͂}���9�s�d��b~�����t����T9�V��8ȴ��YN()���$�L)d!��\�V�<�^�0O��`[!�����:�C�p�Q���%))sڔ^���+��&�Q��%�r�T���
ǘ�c�-t0�;�W%4��`�$�(h]3S@-��RmVRq��R������0[�
̇=�1���PZ�	TNQ֌`���X�JB�)��A�T�@����XmT�-	Qe�KQp����RVk]Ji�|�A�s%�*��]IG�4ޗP��օ�*����Y��Q�%�1%�be�d�#$�>�j�iM�Bk�d8-*b���9�`���f��J����)�k�w����1fxU��B���T��ڗ�s!��j��ҁ��VJ^�*��,g�$���Z�[<VR	lCAJ�y^Prb�t%8}�3������4��-�ҙ���ՊSNJ��.R�gY��I�(5�2�]C�W%�\�T�Dm��,	Vp�����7�*����%�g1FKC=�p�(�I(/ap�� de)pߚ��
*HY��V���(���(�`O�J�G�.mhUJ0�I��* �  Ym$ �
C�S���KE)ÿ��%uJhQ��P��DA��3�x]VJ9ù���YC�=x\���`��� ����w����&�� �j�m��kZ�`(<��5����U ���,�%�@�D�,%��!5�d�ZYyYC]
�
'Jkg�8p;��jF�:(2>V����&�C2�I�r]�)�T�!à�%hbTTY��I�Vw�\�c
 	g3�
ۊxI���m��7���[�m�N��������@��=ڴ���A��<�*������ �Y���M)�I�M�������Ag�{�a�ھ�̅���Z�\��u�&�@,�eH�=�h�MI�rɳ�}���y=�g*����~mS��d?��������+˨זQh{����)i��h���x(1��B؂=T+�G1�_ȩ���G���53��Dolq�8E셄�
�pz��N�1�*|�+�f�e+�([�<���mu��\�}2Q�����ξF��S87�#���R˶��п2�g�|r	���wꎖ�
5�`kP�Pf���"�	��O��������P��~4�[ܻ_�5�W$o�g��M7�τ�lP
�e��k�~1���O$d~J�m�#n�>;�y����M�������!n�� 8Ǣ})?�AB��|��'�O�c�3�∑�B<��{Š�k��������|k��      �   ;  x����n�H���Sp�]d���RKC�8터�4*o�`c(������$i�К�T:��篟;oD��C�e�@3:�1�Q�Nl��F����$[���zq�z
	=<�/�o)Ɇ���zUus�=�IZ~�ٳ�㫁 �&�&Dm-@-��\pʄ	�u�7�L���n������mջ��gF�|�LȄ����uZRs%�d�T!%&Q40=��"O� �AZ�:⼨>����6.�F��Z�N*W���b�U�7M)��A�U�~��z̿���)����PZ v!��b��u�������p�0<���h��s?O�/ծ.D!�ew�/��/�ͺ�s�Bu��}�UOi����G���֫��ee ���?�B�������p��/n��O�2-wخ�U��8t'�s��2X���=@��6Ӱ�8Hpښmc=J�=��;oJ���p����a��o�0T�%[c��E�ۮږaj��P��vs��#@ �fqv��T�^}��:U�����?����&AD�a�0���d"l�[�:��:T|K�L�߇ހ-���ca�D���Ur@�\e������%��Gzڑ�޹�?�!oClAbA��b�/.>�>����dy�m�Dk�owI�WeDa�8��DM��� ������j�+ؒ������=N���̒�^�_��C�vn���K:��/��.�c{�@K7}9��If�;o�*>;�Yv�������v�U��e������v�}�=�~Q]�n��P���d���:�"��G�G&��2���!L�/0@�A[?��V�@w�T      �      x�3�4�4����� 	_      �   q  x��ɑ$I�]¬%<u��X8��!��
0�������!B")���(D�6�/����B�D#Jb��E�o�C��I�'��x����8��g�s��rN�]Ή�˹pv9�O΅�s���\8?MΏ)�S8S8S8����>�sh��94�8����T�L�L�L��+��_18���S��)���>�>�X��Pti�$����.�_Pѥ�*�4~AE��/���pVti8+�4�]:Ί.gE����K�Yѥ���q�p�p�pVt�8+�|8+�|8+�|8+�|8+�|8+�|8'S8+�|8+�|8+�|8+��]�D8���s�\r�K΁s�9p.9�%����8���s��rN�[Ήs�9qn9'�-�Ĺ�8���s��r.�GixH�y����wxH�y����wxH�y����wyH�y����wyH�y����wq�λ8k�]���.��yg����v���ZKK᭭�0��R�ko)��P��� �CA�@��D�c`��a0�Y����e�`���؛��7c����|,�wz>6t;Ɋ�'��;	��}�������}��N����}��h�͠���I�l�Q�f������(�,������(�,������(�l������(�l��L6�
&g咍�2��Rɾ��P��(��=���;%��S���2(���4(���6(���8(���:(��c(��c(��c����	M�w>$R�"���H��U}�c"5(�W����%?)'y�߹�R�0F�p�a�0F�p�6MF�x0ƃ�0�	�1�0����7#nF�_��+�l�HfF2[0�ق�7#oF���o+�~#ٯa$��Q0F�h�a��Q0F�h�a��Q0F�c`4���0F�c`4��qi`�AZw����qia�AZw����qia�AZw�I-A
I-A
I�U({�0�fap��>/��$�Im(}ґv��I@v%� �]K8HfW�����dvE� ���dv4������xݦK���!������t�zc��{�1��ޘn�^od�b]��ޘ�^o���7�`�{0���x0���x0�=�����A�,`�/�����A�,`��0F�#a�CK��=��A-a�CK��=��A-a�CK��
=��A�`�C+��
=��A�`�C+��
=��A�a�Ck��=��A�a�Ck��=��A�a�Ck��=��Am`�C��=��Am`�C����p`\��Xca,���0��ua\_��ua\_��ua�W�`�W�`\_��|''2O�N&�OrN6rO��$4;}u;}u;}u;�Z�����?��5      �   >   x�3�t300�C�4�4�2���4�2�t�� ����č�-8�P�%Pg� �@�      �   8  x�mZ[�,�
��L����˝�8�Z`UoȎ8y6X��A�G���>���_�س?������G�](��G�364�#�9�����HO릯������2�]`k��S?��ݟ~Yz�?�#�����#��_���G���h��l|?d�=���vyt��Y����F| X��v��c��۝L�������K&L1����/>T�ӳ�)����W�36���u��eW�_�Ӟ�*���O��.�?�s����&�~�����_���ϐb ,ֺ#����R�=6����� �*�zF�Iz}�e$�\�����䴱��t�3[���5��t��Pu�V"P*�=ٗ�}M���� 4��zz�3�����\��;�_���4O/��̑N�w����.-2�!�Ջ� ��Y#��▾�	���K¿p����R&�#z�NX��r8
�i��Y���l)��
;�	\k�|�����J�<��.�;���!�=
��i���ݛk!�}�n��='k�P�vr��OB�G3T��s�)���X�����D9 `ϩ8�� :,�+�ذ���M�NZ9]��r�u�0��^|4�
D5O"���t0�)�Yɉ�f���mWZm���ſ��m@�P���Zx�H�d�n:R�4��a�JY��� i\��/"�;rJ����Iͤk��6"�d�ms� 	ʑ9;��#W��l� �p�Z�6�95"ڋ�z�U���s��CZ-׮a��o�n��Lh����'4�����ل����a���zM ��
pD�w�;�00r�i�6�n��� ����J.C2�?��7�����bڳ{�B���p/s���G]���BF��9C)7Y�T�;�v}=�g��*��`��9�΅�Fv�k5�Ҳ�Ϋs+G��/��$]rb=��jaO�=(��dEA:V���I��l��|%��
�k����"��W�������{KV�l��/SJ��U D3k��N���e�;4��|��a�<���To2"hP��$�d M(,��Y,XM��*V�Y.'�%��k�K3���V9�î��9�4�eɘ�Mh+W}k� V�V�=�T��(�ؿT������nn2[�Er�5.��"�W�����SV���֠��#'K�纁�wnv�֎Jv���j7A�����󶓒Cվ	E��X�o�8��n�g����s�y(�V�%� x,E*��+�=�!m=1x�T�2�~>�B4�(f�nz�n��0��u �����mɡ!�ZΜhW���_���Urhc��Ц����\m�79�*�0NLTV&������/m��9���Õ�БKg��Q�)�c ���uJ�dD��SS��e� ���X���t�������PG:�D�pgh%�xeQ�����WǜB���H+{G9�K*%NpHi�|���ŷj!fs��"��u�cTN�n_�C`��J��pz�ک	8lr�����?��W��*J����B���S�3�2ԕ#F-��:41��D���g9`�zh˔��kow�(0��L�����KE=5�9\1�wW���"�p����~r$��T�H��������G��N�e�b!t��E ��t��7��i�Ha+R}o��U"���e�ĩ\����x�|3�w:v����k��^��v''�Z�`��q���7Y՝�u�6p<����٥gn5
�^���8��pջ��a��l�R/�4��������D��Z-��2XH��a��W��l ^�>�k>�,u6��p5젏�o��s�,w^��,!i�硅�iP����2u*)��(C�;��$?���Qf��y�������9w/;z��C{L����#�Vyr��yB�������枞=�K�Za����$�o�R�@���JE�� �� �xN�4++��b�P��Yy�B���.۞{up��2�K��ܗC��Fd�>�n	'��kV�3��<��D`��7��{��08`X����Y��`g;����V5#F�}�"�j_�B��0+51$�FAG ���ƉU������HdU?�·�&|��K��i�?����g��?�_�rD���n��E�v3�YG���ob0�/m���}�Rή=�R��M0��C�/��]ΘO������F��YL�Bۧ9J�~�]��uNg)�s�E;�O����)̼���t�>�� ƀS�$98E\��ϼ�����1l��͝yL�^N���(JX�����C؁&Er���r{���� f��{�|��V�]�9��G��%L��@�,�قS�/)��HuCVY9j�I����AU���U�r����o��_e:�tޗ��s}�Or�Dx�ƛ�p��dN�:d�(�T�8�bc�R笨Zƨij_A�<�q���^(��
;X1j�Z8�����3VZ�waÊ���aE�;f��^}��j�n�����
�*!a��Ǩ�y_��y_��5S�6�^�L� \R��:{))wt)��v\o�iED;D�N͈��?(9j_����u�y�x��7'x4�U.8£��+C�*�Ub�������a�V�J亳����>��}���Ƹγ�R��vމ���^	�������7�L��!����/Sq:��oY�ڿ���u缏���8�.}ŉ�b���p��.����.��Q��y=�����iI�>:�O��pz�N�`>U%�6��R�ϗ�8D��_ï^��Ng>뵞��8��!�\�󔓑�y�@�<��6����\aӳ�-X{�8iQtX�G���,�(��9�Fi��Z�W�9�!�d���P�4�k�"������͙I� :�OD=��fG�U��Z��7�����j6�E�����^��T�P2���ʹ�Ј�'�%�J<q�^�3����J˹%�r�<Qq8��t�p�|_@�jE�>N����]���p/��S8�Gv|�%YzT��m&�6�&�p��zm��Gzw��1��^��?�BY�R��3+��z'}��땀c���4_�����G��`$��zB�B)v��i��z'|?g/��Z�Q=�񙶍�����<j+���U�9������^n�p���Pc�h�s���8�W膇8%ˊ�(�����<��r�      �      x�3��t�4��30�,����� $@P      �   8   x�3�tst	r�,�4�2�,N-..����9��}\C Hʌ�,R�\1z\\\ I"Y      �   �  x���ˮ$7��u��X߷Yd�'�m֑���.��U�>�F���/�S�������G�x@��z<0b���������{��t�tj���~��Ő�%E����)q�Ci
�",-d�я�UO��[my� ��9��$$m2Y�7�B�]\Гv�+v�:d�%��O�8��R������\�:XI{�Ne=ҹ�@���}�xj�vc-CA#�2���W�YL�!Nq����d{A��d�������:E����!�1�E����k�R���3Z4��'��Nq��pF���j\�{���a���#��r�P���.72ad�rM�ޢ�L�(bF�l;��e]mt 2`3�$�f�:h0�Y�2`dq��1Pq��D�{f���5��5���%p�ĺ�L�>G]�h�\%�~�/��D*u�V����"�q3�����71[i��D�=\1�5	<�Z�D�)�b�iɏ����"[OWu�bw�LY>��4gW�\��.K�\�ݭ3޸J��.޾��3�E6-1%��5 �+��V^�=�6��X\1�E�?���"��m���"�ƌs�BV���d��y,�,1��\�A�	���?h��,�/�Gw�ُ��"[β8X�C��X��]*RpE?�XR�L�W�L>4�y�T�h���<F�l]�����}k�z��lY91���.vq�*Lٴv�j�5����.f����R���m�1ČWY��*Uhz$���"K'��\Lc�4G\/�me�2f��9��������q��F]��]1Fv�mnuͮ���PK�S1�x�ZW��we��.3^�,R櫖��L��j�[r��Y�� ������/��Dj�$+�Cͮc�k����oSn��:�9^�>�b��M�k�j(�b3���;�>��]��"���U�s��3�Evs������-�ثƄ��M��g&��ң!e���E�1d�kfA���Z�]�:����4Č���b��o�����"���a���.��6��Zwf����LY��eH�+����%f<���r;Ń���c��g�j��V���y0su+ߎu��]��p�-+��m�J�_q�3c_�b��y�x�tμ˳���R�?F�\7�R�Q�{�˗%�ö|��(º�ϫ!��$�z~ܴ�ښ�G��U��*3�Қ�]�MǒKs�MUS.�����w�P���r�Q����Kf`�ܻ��a6�6���)��϶bK�y���4Ϝ�䐲�
/�Ͱ�-��uHg��|T�_�/����P@����ub��S����/���Y��l�Bk�-yZ�O�̔U^7�=����yK-�qH�/7�\�Kt3X����C1�ѩK�R��f��Ү������y[r!.�c]���-eV�k�pU��S�%��^��}�Mb���.�/Z�I役r�z/gϊ�3����˅�LnVv�1��Ѫm�3t���h���<�}sK.Ԕ�;k�Z�)��������b�\p�%�U�0����!�!��wynY\[�"�%K.����}���ig�f��\��	��>+���RQ����tá��%�mel��wb���m�l��
���%�h�yM=� ]����6!��ʶ����Sv9��~4.��n}e�f�E�N�+�߻tɡ�m�ǘ���a6��Ƨ:�oYz07��v���C�5v�n��Zr��m?�O�or�n��Ҋ�-d���Q��B]۶pM�@�6�S,ȵ2�+��+�C�ݕK���ڿ4�rA�m�}�X����]�^iAþoeɥ9	|��w���}��V�M~=j`F�7��� C'�Ibf�}[,mJտ�=���z�g=�E7M�.��*at����]x�k�=��yK��7��<pY�u�4�z<��KD��yX5y�BQ,gF=v��y���%�O����%��?��QSZ�I�����H�����A-/���f���?��X�i�o�����A.����� ??'�=EH�7�E�֧���\��ݟ��͞q�ٟ�ƒ�����x�����A�O��1V>m#��Sb?5_/́�@~q�����F��z�_o���l�k<x�h��鱽�=n'/���[ԃ\��K�.�Xr�7-)[.�X��*?�Zj��.�i1��"	�g��h�[�or}�)�XDm%ٟj�u)�7��P��Gs��z.[ֶ������|��]W���;��;��X��_(XL�����M�'Ʃ��̃\�I~b}P�+���b9*���e�%�ǿ������O�
___��
�     