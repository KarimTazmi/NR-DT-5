--5.1 Hoe presteren de merken tegenover elkaar?
select
	brandname,
	sum(purchaseprice),
	count(t.transactionid),
	date_trunc('year', t.transactiondate)
	as date,
	sum((t.purchaseprice - rb.wholesalecost)) as winst
from
	rootbeer r
left join transaction t on 
	r.rootbeerid = t.rootbeerid
left join 
	rootbeerbrand rb 
	on rb.brandid = r.brandid
where 
	transactiondate is not null 
group by 
	brandname,
	date 
order by count(t.transactionid) asc

