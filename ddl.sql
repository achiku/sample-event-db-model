DROP TABLE IF EXISTS offer;
DROP TABLE IF EXISTS cancel;
DROP TABLE IF EXISTS event;

create table event (
  id serial primary key
  , name text not null
  , created_at timestamp without time zone not null
);

create table cancel (
  id serial primary key
  , event_id integer not null
  , cancel_event_id integer not null
  , name text not null
  , created_at timestamp without time zone not null
  , FOREIGN KEY(event_id) REFERENCES event (id)
  , FOREIGN KEY(cancel_event_id) REFERENCES event (id)
);

create table offer (
  id serial primary key
  , event_id integer not null
  , offer_event_id integer not null
  , name text not null
  , created_at timestamp without time zone not null
  , FOREIGN KEY(event_id) REFERENCES event (id)
  , FOREIGN KEY(offer_event_id) REFERENCES event (id)
);


insert into event (id, name, created_at) values (1, 'normal event 01', now());
insert into event (id, name, created_at) values (2, 'normal event 02', now());
insert into event (id, name, created_at) values (3, 'normal event 03', now());
insert into event (id, name, created_at) values (4, 'normal event 04', now());

insert into event (id, name, created_at) values (5, 'cancel event 05', now());
insert into cancel (event_id, cancel_event_id, name, created_at) values (5, 1, 'cancel event 05 for event 01', now());

insert into event (id, name, created_at) values (6, 'cancel event 06', now());
insert into cancel (event_id, cancel_event_id, name, created_at) values (6, 1, 'cancel event 06 for event 01', now());

insert into event (id, name, created_at) values (7, 'offer event 07', now());
insert into offer (event_id, offer_event_id, name, created_at) values (7, 2, 'offer event 07 for event 02', now());



select
  e.id
  , e.name
  , c.event_id as c_evt_id
  , c.cancel_event_id as c_tgt_id
  , o.event_id as o_evt_id
  , o.offer_event_id as o_tgt_id
  , c.name as c_evt
  , c2.name as ced_evt
  , c2.cancel_event_id as ced_id
  , o.name as o_evt
  , o2.name as oed_evt
  , o2.offer_event_id as o_id
from event e
left outer join cancel c
on e.id = c.cancel_event_id
left outer join cancel c2
on e.id = c2.event_id
left outer join offer o
on e.id = o.event_id
left outer join offer o2
on e.id = o2.offer_event_id
order by e.created_at
;


--  id |      name       | c_evt_id | c_tgt_id | o_evt_id | o_tgt_id |            c_evt             |           ced_evt            | ced_id |            o_evt            |           oed_evt           | o_id
-- ----+-----------------+----------+----------+----------+----------+------------------------------+------------------------------+--------+-----------------------------+-----------------------------+------
--   1 | normal event 01 |        6 |        1 |          |          | cancel event 06 for event 01 |                              |        |                             |                             |
--   1 | normal event 01 |        5 |        1 |          |          | cancel event 05 for event 01 |                              |        |                             |                             |
--   2 | normal event 02 |          |          |          |          |                              |                              |        |                             | offer event 07 for event 02 |    2
--   3 | normal event 03 |          |          |          |          |                              |                              |        |                             |                             |
--   4 | normal event 04 |          |          |          |          |                              |                              |        |                             |                             |
--   5 | cancel event 05 |          |          |          |          |                              | cancel event 05 for event 01 |      1 |                             |                             |
--   6 | cancel event 06 |          |          |          |          |                              | cancel event 06 for event 01 |      1 |                             |                             |
--   7 | offer event 07  |          |          |        7 |        2 |                              |                              |        | offer event 07 for event 02 |                             |
-- (8 rows)
