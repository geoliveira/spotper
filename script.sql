create database BDSpotPer_FINAL
on
	primary
	(
	name = 'BDSpotPer',
	filename = 'C:\FBD_FINAL\BDSpotPer.mdf',
	size = 5120KB,
	filegrowth = 1024KB
	),

	filegroup BDSpotPer_fg01
	(
	name = 'BDSpotPer_001',
	filename = 'C:\FBD_FINAL\BDSpotPer_001.ndf',
	size = 1024KB,
	filegrowth = 30%
	),
	
	(
	name = 'BDSpotPer_002',
	filename = 'C:\FBD_FINAL\BDSpotPer_002.ndf',
	size = 1024KB,
	maxsize = 3072KB,
	filegrowth = 15%
	),

	filegroup BDSpotPer_fg02
	(
	name = 'BDSpotPer_003',
	filename = 'C:\FBD_FINAL\BDSpotPer_003.ndf',
	size = 2048KB,
	maxsize = 5120KB,
	filegrowth = 30%
	)

	log on 
	(
	name = 'BDSpotPer_log',
	filename = 'C:\FBD_FINAL\BDSpotPer_log.ldf',
	size = 1024KB,
	filegrowth = 10%
	);

use BDSpotPer_FINAL;

create table gravadora(
	cod smallint not null,
	endereco varchar(100) not null,
	pagina varchar(100) not null,
	nome varchar(20) not null,
	constraint PK_GRAV primary key (cod)

) on BDSpotPer_fg01;

create table album(
	cod smallint not null,
	cod_grav smallint not null,
	nome varchar(50) not null,
	descr varchar(100) not null, 
	tipo_compra varchar(20) not null,
	pr_compra dec(5,2) not null,
	dt_compra date not null,
	dt_gravacao date not null,
	
	constraint PK_ALBM primary key (cod),
	constraint FK_GRAV_ALBM foreign key (cod_grav) references gravadora,
	constraint TIPO_DA_COMPRA check (tipo_compra like 'fisica' or tipo_compra like 'download'),
	constraint DATA_COMPRA_SEC_XXI check (dt_compra > '01/01/2000')

) on BDSpotPer_fg01;

create table telefone(
	numero varchar(13) not null,
	cod_grav smallint not null,
	constraint PK_TEL primary key (numero),
	constraint FK_GRAV_TEL foreign key (cod_grav) references gravadora

) on BDSpotPer_fg01;

create table composicao(
	cod smallint not null,
	nome varchar(20) not null,
	descr varchar(100) not null,

	constraint PK_COMPOSICAO primary key (cod)

) on BDSpotPer_fg01;

create table faixa(
	numero smallint not null,
	cod_album smallint not null,
	descr varchar(100) not null, 
	tempo time(0) not null,
	tipo_composicao smallint not null,
	tipo_grav varchar(3) not null

	constraint FK_ALBUM_FAIXA foreign key (cod_album) references album on delete cascade,
	constraint ADD_OU_DDD check (tipo_grav like 'ADD' or tipo_grav like 'DDD')
	
) on BDSpotPer_fg02;

create table playlist(
	cod smallint not null,
	nome varchar(20) not null,
	dt_criacao date not null,
	dt_ult_reprod date not null,
	num_reprod smallint not null,
	tempo time(0) not null,

	constraint PK_PLAYLIST primary key (cod)

) on BDSpotPer_fg02;

create table faixa_playlist(
	numero_faixa smallint not null,
	cod_album smallint not null,
	cod_playlist smallint not null,

	constraint FK_PLAYLIST_FP foreign key (cod_playlist) references playlist

) on BDSpotPer_fg02;

create table interprete(
	cod smallint not null,	
	nome varchar(20) not null,
	tipo varchar(20) not null,

	constraint PK_INTERP primary key (cod)

) on BDSpotPer_fg01;

create table faixa_interprete(
	numero_faixa smallint not null,
	cod_album smallint not null,
	cod_interp smallint not null,

	constraint FK_INTERP_I foreign key (cod_interp) references interprete

) on BDSpotPer_fg01;

create table compositor(
	cod smallint not null,	
	nome varchar(20) not null,
	local_nasc varchar(100) not null,
	dt_nasc date not null, 
	dt_morte date,

	constraint PK_COMPOSITOR primary key (cod)

) on BDSpotPer_fg01;

create table faixa_compositor(
	numero_faixa smallint not null,
	cod_album smallint not null,
	cod_composit smallint not null,

	constraint FK_COMPOSIT_C foreign key (cod_composit) references compositor

) on BDSpotPer_fg01;

create table periodo_musc(
	cod smallint not null,
	descr varchar(100) not null,
	intervalo varchar(30) not null, 

	constraint PK_PERIODO primary key (cod)

) on BDSpotPer_fg01;

create table compositor_periodo_music(
	cod_composit smallint not null,
	cod_periodo smallint not null,

	constraint FK_COMPOSIT_CPM foreign key (cod_composit) references compositor,
	constraint FK_PERIODO_CPM foreign key (cod_periodo) references periodo_musc

) on BDSpotPer_fg01;


/* 3.a) Um álbum, com faixas de músicas do período barroco, só pode ser adquirido, caso o tipo de gravação seja DDD.
 */

create view album_com_faixa_barroca_add
as
select distinct a.cod, f.numero
	from periodo_musc pm inner join compositor_periodo_music cpm on pm.cod=cpm.cod_periodo and descr like 'Barroco'
			inner join compositor c on cpm.cod_composit=c.cod
			inner join faixa_compositor fc on c.cod=fc.cod_composit
			inner join faixa f on fc.cod_album=f.cod_album and fc.numero_faixa=f.numero and f.tipo_grav like 'ADD'
			inner join album a on f.cod_album=a.cod
	group by a.cod, f.numero

create trigger BARROCO_COM_DDD_FC on faixa_compositor for insert, update
as
if exists (select cod_album from inserted where cod_album in (select distinct cod from album_com_faixa_barroca_add))
begin
	raiserror('Um álbum, com faixas de músicas do período barroco, só pode ser adquirido, caso o tipo de gravação seja DDD!', 16, 1)
	rollback transaction
end

create trigger BARROCO_COM_DDD_F on faixa for insert, update
as
if update(tipo_composicao) or update(tipo_grav)
begin
	if exists (select cod_album from inserted where cod_album in (select distinct cod from album_com_faixa_barroca_add))
	begin
		raiserror('Um álbum, com faixas de músicas do período barroco, só pode ser adquirido, caso o tipo de gravação seja DDD!', 16, 1)
		rollback transaction
	end
end

/* 3.b) Um álbum não pode ter mais que 64 faixas (músicas)
 */
create trigger MAX_FAIXAS on faixa for insert, update
as
begin
	declare @cod_album smallint, @QTDE_FAIXAS int

	select @cod_album=cod_album from inserted

	select @QTDE_FAIXAS=count(*) from faixa where cod_album=@cod_album group by cod_album

	if (@QTDE_FAIXAS > 64)
	begin
		raiserror('Numero maximo de faixas execedido!', 16,1)
		rollback transaction
	end
end

/* 4) Defina um índice primário para a tabela de Faixas sobre o atributo código do álbum.
	Defina um índice secundário para a mesma tabela sobre o atributo tipo de composição. Os dois com taxas de preenchimento máxima.
   
   3c) No caso de remoção de um álbum do banco de dados, todas as suas faixas devem ser removidas. Lembre-se que faixas podem apresentar,
       por sua vez, outras associações.
   FOI ADICIONADO NAS FK DAS TABELAS AUXILIARES A FAIXA 'on delete cascade' TAMBEM
*/
create clustered index IDP_COD_ALBUM on faixa(cod_album) with (fillfactor=100)
alter table faixa add constraint PK_FAIXA primary key (numero, cod_album);

alter table faixa_playlist add constraint FK_FAIXA_FP foreign key (numero_faixa, cod_album) references faixa on delete cascade;
alter table faixa_interprete add constraint FK_FAIXA_I foreign key (numero_faixa, cod_album) references faixa on delete cascade;
alter table faixa_compositor add constraint FK_FAIXA_C foreign key (numero_faixa, cod_album) references faixa on delete cascade;

create nonclustered index IDS_FAIXA_TP_COMPOSICAO on faixa(tipo_composicao) with (fillfactor=100)
alter table faixa add constraint FK_COMPOSICAO_FAIXA foreign key (tipo_composicao) references composicao

/* 5) Criar uma visão materializada que tem como atributos o nome da playlist
		e a quantidade de álbuns que a compõem.
 */ -- OBS: a tabela playlist tem participacao total com a tabela faixa (fazer com banco povoado)

create view V5 (cod_playlist, cod_faixa, cod_album, qtd_albuns)
with schemabinding
as
select p.cod, f.numero, f.cod_album, count_big(*)
	from dbo.playlist p inner join dbo.faixa_playlist fp on p.cod=fp.cod_playlist
		 inner join dbo.faixa f on fp.numero_faixa=f.numero
	group by p.cod, f.numero, f.cod_album

create clustered index IDP_V5 on V5(cod_playlist) with (fillfactor=100);

create view V5b (nome_playlist, qtd_album)
as
select p.nome, count(cod_album) from V5 inner join playlist p on p.cod=cod_playlist group by cod_playlist, p.nome

/* 6) Defina uma função que tem como parâmetro de entrada o nome (ou parte do)
		nome do compositor e o parâmetro de saída todos os álbuns com obras
		compostas pelo compositor.
 */ 

create function album_compositor (@nome varchar)
	returns @tabela_obras table
	(albuns_compositor nvarchar(30))
as
begin
	insert into @tabela_obras
	select distinct a.nome from compositor c, faixa_compositor fc, faixa f, album a 
		where c.nome like ('%'+@nome+'%') and c.cod=fc.cod_composit
			  and fc.numero_faixa=f.numero and f.cod_album=a.cod
	return			
end


------------------------------ VIEWS UTILIZADAS NAS CHAMDAS DO APLICATIVO .py --------------------------------------


/* 8a) Listar os álbum com preço de compra maior que a média de preços de compra de todos os álbuns.
 */

create view oitoa as
select a.nome, a.pr_compra from album a where a.pr_compra >= all (select avg(pr_compra) from album)


/* 8b) Listar nome da gravadora com maior número de playlists que possuem pelo uma faixa composta pelo compositor Dvorack.
 */

create view faixas_de_dvorack
as
select f.numero, f.cod_album
	from compositor c left outer join faixa_compositor fc on c.nome like 'Dvorack' and c.cod=fc.cod_composit
		 inner join faixa f on f.numero=fc.numero_faixa and f.cod_album=fc.cod_album


create view qtd_playlist_faixas_dvorack
as
select a.cod_grav, g.nome as nome_grav, a.nome as nome_album, f.cod_album, f.numero, count(fp.cod_playlist) qtd_playlists
	from faixas_de_dvorack f left outer join faixa_playlist fp on f.numero=fp.numero_faixa and f.cod_album=fp.cod_album
		 inner join album a on f.cod_album=a.cod
		 inner join gravadora g on a.cod_grav=g.cod
	group by a.cod_grav, g.nome, a.nome, f.cod_album, f.numero


create view oitob as
select qpfd.nome_grav, sum(qtd_playlists) as qtd_de_faixas_em_playlists from qtd_playlist_faixas_dvorack qpfd
	group by cod_grav, qpfd.nome_grav
	having sum(qtd_playlists) >= all (select sum(qtd_playlists) from qtd_playlist_faixas_dvorack qpfd group by cod_grav)


/* 8c) Listar nome do compositor com maior número de faixas nas playlists existentes.
 */

create view compositor_e_faixas
as
select c.cod, c.nome, f.cod_album, f.numero, count(fp.cod_playlist) qtd_playlists
	from compositor c left outer join faixa_compositor fc on c.cod=fc.cod_composit
		 inner join faixa f on f.numero=fc.numero_faixa and f.cod_album=fc.cod_album
		 left outer join faixa_playlist fp on f.numero=fp.numero_faixa and f.cod_album=fp.cod_album
	group by c.cod, c.nome, f.cod_album, f.numero

create view compositor_por_playlist
as
select c.nome, sum(qtd_playlists) sum_qtd_playlists from compositor_e_faixas c group by c.cod, c.nome


create view oitoc as
select c.nome, sum_qtd_playlists from compositor_por_playlist c where sum_qtd_playlists >= all (select sum_qtd_playlists from compositor_por_playlist)


/* 8d) Listar playlists, cujas faixas (todas) têm tipo de composição “Concerto” e período “Barroco”.
 */

drop view faixa_concerto_barroca
create view faixa_concerto_barroca
as
select f.cod_album, f.numero, co.nome
	from composicao co inner join faixa f on co.nome like 'Concerto' and co.cod=f.tipo_composicao
		 inner join faixa_compositor fc on f.numero=fc.numero_faixa and f.cod_album=fc.cod_album
		 inner join compositor c on fc.cod_composit=c.cod
		 inner join compositor_periodo_music cpm on c.cod=cpm.cod_composit
		 inner join periodo_musc pm on cpm.cod_periodo=pm.cod and pm.descr like 'Barroco'
	group by f.cod_album, f.numero, co.nome

create function eh_concerto_barroca(@numero smallint, @album smallint)
returns int
as
begin 
	declare @retorno int

	select @retorno=count(*) from faixa_concerto_barroca where @numero=numero and @album=cod_album
	
	return @retorno
end

create view oitod
as
select distinct p.cod, p.nome, p.dt_criacao, p.dt_ult_reprod, p.num_reprod
	from playlist p inner join faixa_playlist fp on p.cod=fp.cod_playlist
		 inner join faixa f on f.numero=fp.numero_faixa and f.cod_album=fp.cod_album
	group by p.cod, p.nome, p.dt_criacao, p.dt_ult_reprod, p.num_reprod, p.tempo, f.numero, f.cod_album
	having dbo.eh_concerto_barroca(f.numero, f.cod_album) = 1


----- VIEW MOSTRA FAIXAS DAS PLAYLISTS

drop view faixas_playlists
create view faixas_playlists
as
	select p.cod as cod_playlist, a.cod as cod_album, f.numero as numero, f.descr as descr, f.tempo as tempo, c.nome as composicao, f.tipo_grav
	from playlist p left outer join faixa_playlist fp on p.cod=fp.cod_playlist
		inner join faixa f on fp.cod_album=f.cod_album and fp.numero_faixa=f.numero
		inner join album a on f.cod_album=a.cod
		inner join composicao c on f.tipo_composicao = c.cod
	group by p.cod, p.nome, a.cod, f.numero, a.nome, f.descr, f.tempo, c.nome,  f.tipo_grav












