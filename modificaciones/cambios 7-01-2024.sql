DROP FUNCTION IF EXISTS public.fn_historal_atencion_mascota(integer);

CREATE OR REPLACE FUNCTION public.fn_historal_atencion_mascota(
	id_masc integer)
    RETURNS TABLE(id_atencion integer, nombre character varying, descripcion character varying,comentario text,monto numeric, entrada timestamp with time zone,salida timestamp with time zone) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
begin
	return query
	select ga.id_atencion,gm.nombre, gs.descripcion,ga.comentario ,gd.monto,ga.entrada,
	CASE
        WHEN ga.salida = ga.entrada THEN null
        ELSE ga.salida
    END AS salida
	from gestion_detalle_atencion as gd
	inner join gestion_servicio as gs on gd.id_servicio_id=gs.id_servicio
	inner join gestion_atencion as ga on gd.id_atencion_id=ga.id_atencion 
	inner join gestion_mascota as gm on ga.id_mascota_id=gm.id_mascota
	where gm.id_mascota=id_masc
	order by ga.salida;
end;
$BODY$;