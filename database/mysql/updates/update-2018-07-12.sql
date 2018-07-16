create table if not exists document_review
(
  id int auto_increment primary key,
  document_no int(20) not null,
  provider_no varchar(6) not null,
  date_reviewed datetime,
   foreign key(document_no) references document(document_no),
   foreign key(provider_no) references provider(provider_no)
);

insert into document_review (document_no, provider_no, date_reviewed)
  select d.document_no, d.reviewer, d.reviewdatetime
  from document d
  where d.reviewer is not null and d.reviewer != '' and d.reviewer != 'null';