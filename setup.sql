--5.1 Hoe presteren de merken tegenover elkaar?

-- Selecteren van aantal purchases per merk + winst
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

-- Selecteren omzet, winst en percentage totaal
select
    brandname,
    sum(t.purchaseprice) as omzet,
    sum((t.purchaseprice - rb.wholesalecost)) as winst,
    100*(t.purchaseprice / SUM(rb.wholesalecost) over () )as "Winstpercentage",
	count(t.transactionid),
	date_trunc('year', t.transactiondate) as date
from
    rootbeer r
left join
	transaction t 
    on r.rootbeerid = t.rootbeerid
left join
	rootbeerbrand rb 
    on rb.brandid = r.brandid
	where 
        transactiondate is not null 
    and 
        wholesalecost is not null
    and 
        purchaseprice is not null
group by 
    brandname,
    rb.wholesalecost,
    t.purchaseprice
order by 
    "Winstpercentage" desc

--5.2 Hoe ontwikkelt de bruto winst zich per locatie?
select
    brandname,
    t.locationid,
    sum(t.purchaseprice) as omzet,
    sum((t.purchaseprice - rb.wholesalecost)) as winst,
    100*(t.purchaseprice / SUM(rb.wholesalecost) over () )as "Winstpercentage",
    date_trunc('month', t.transactiondate) as date
from
    rootbeer r
left join
    transaction t on r.rootbeerid = t.rootbeerid
left join
    rootbeerbrand rb on r.rootbeerid = t.rootbeerid
where 
    transactiondate is not null 
    and wholesalecost is not null
    and purchaseprice is not null
group by
    t.locationid,
    brandname,
    t.purchaseprice,
    rb.wholesalecost,
    date
order by 
    "Winstpercentage" desc

--5.3 Wat zijn de gevolgen als de bieren nog maar 60 dagen ipv 90 dagen op voorraad worden gehouden?

-- Berekenen van winstverlies
select 
    sum(profit) as winst_huidig,
    sum(profit_61_days_stock) as winst_nieuw
from (
	select t.purchaseprice - b.wholesalecost as profit, 
    case when 
        (t.transactiondate - r.purchasedate) > 60 
        then purchaseprice - wholesalecost 
        end as profit_61_days_stock
	from 
        rootbeer.rootbeer r
	join 
        rootbeer."transaction" t on r.rootbeerid = t.rootbeerid
	join 
        rootbeer.rootbeerbrand b ON r.brandid = b.brandid
	group by 
        t.purchaseprice, 
        b.wholesalecost, 
        t.transactiondate, 
        r.purchasedate
) as 
    dataframe

-- Berekenen van voorraad over 60
select 
    b.brandname,
    Count(t.transactionid) over_60
from   
    rootbeer.rootbeer r
join 
    rootbeer."transaction" t
    ON r.rootbeerid = t.rootbeerid
join 
    rootbeer.rootbeerbrand b
    ON r.brandid = b.brandid
where  
    ( t.transactiondate - r.purchasedate ) > 60
group by b.brandname;

--5.4 Deze organisatie is er van overtuigd dat rootbeer rietsuiker (en soms honing) als zoetstof moet gebruiken in plaats van maïssuiker of kunstmatige zoetstoffen.
-- Winst per merk per type zoetstof
select
	b.brandname,
    case when 
        b.canesugar = TRUE 
        then (t.purchaseprice - b.wholesalecost) 
        end as profit_canesugar,
    case when 
        b.cornsyrup = TRUE 
        then (t.purchaseprice - b.wholesalecost) 
        end as profit_cornsyrup,
    case when 
        b.honey = TRUE 
        then (t.purchaseprice - b.wholesalecost) 
        end as profit_honey,
    case when 
        b.artificialsweetener = TRUE 
        then (t.purchaseprice - b.wholesalecost)
        end as profit_artificialsweetener
from
    rootbeer."transaction" t
join 
    rootbeer.rootbeer r
    on r.rootbeerid = t.rootbeerid
join 
    rootbeer.rootbeerbrand b
    on b.brandid = r.brandid
group by
b.brandname,
    profit_canesugar,
    profit_cornsyrup,
    profit_honey,
    profit_artificialsweetener
order by
	brandname desc