--SPRINT GROWTH
with t1 as 
(select date(sales_transaction_date)as Date,count(product_id)as Units_Sold,sum(count(product_id))
over(order by date(sales_transaction_date)
rows between 6 preceding and current row ) as Cumulativecurrent_7D from sales s
where product_id =7
group by date(sales_transaction_date)
order by 1 limit 15 offset 6)

select t1.*,lag(Cumulativecurrent_7D)over(order by Date)as Prior_period_sales,
(Cumulativecurrent_7D-lag(Cumulativecurrent_7D)over(order by Date))*100/lag(Cumulativecurrent_7D)over(order by Date) as growth_perc from t1

--SPRINT LTD GROWTH

with t2 as 
(select date(sales_transaction_date)as Date,count(product_id)as Units_Sold_Ltd,sum(count(product_id))
over(order by date(sales_transaction_date)
rows between 6 preceding and current row ) as Cumulativecurrent_7D_Ltd from sales s
where product_id =8
group by date(sales_transaction_date)
order by 1 limit 16 )

select t2.*,lag(Cumulativecurrent_7D_Ltd)over(order by Date)as Prior_period_sales,
(Cumulativecurrent_7D_Ltd-lag(Cumulativecurrent_7D_Ltd)over(order by Date))*100/lag(Cumulativecurrent_7D_Ltd)over(order by Date) as growth_perc_Ltd from t2

--COMPARISON

with t1 as 
(select date(sales_transaction_date)date,count(product_id)as units_sold_Sprint,case when
row_number()over(order by date(sales_transaction_date))>6 then
sum(count(product_id))
over(order by date(sales_transaction_date)
rows between 6 preceding and current row ) else null  end as Sprint_CL_cumulative_7_days ,
row_number()over(order by date(sales_transaction_date))as Day from sales s
where product_id =7
group by date(sales_transaction_date)
),


 t2 as 
(select date(sales_transaction_date)date_ltd,count(product_id)as units_sold_Sprint_Ltd,
case when row_number()over(order by date(sales_transaction_date))>6 then
sum(count(product_id))
over(order by date(sales_transaction_date)
rows between 6 preceding and current row ) else null end as Sprint_Ltd_CL_cumulative_7_days,
row_number()over(order by date(sales_transaction_date))as Day from sales s 
where product_id =8
group by date(sales_transaction_date)
)

select a.Day,a.units_sold_Sprint,b.units_sold_Sprint_Ltd,a.Sprint_CL_cumulative_7_days,
b.Sprint_Ltd_CL_cumulative_7_days from t1 a join t2 b on 
a.Day=b.Day
order by a.Day limit 22


--EMAIL ANALYSIS
--Benchmark-email opening rate-18%
--Benchmark-clickrate-8%

with t1 as(
 select  es.email_subject_id,es.email_subject ,e.sent_date,count(e.email_id)email_sent,
 sum(case when opened='f' then 0 else 1 end) as opened,
 sum(case when clicked='f' then 0 else 1 end) as clicked,
 sum(case when bounced='f' then 0 else 1 end) as bounced,18 as opening_bench_mark,8 as click_bench_mark
 from emails e join 
 email_subject es on e.email_subject_id=es.email_subject_id 
 group by es.email_subject_id,es.email_subject, e.sent_date)
 select t1.*,cast(t1.opened*100.0/(t1.email_sent-t1.bounced) as DECIMAL(10, 2))as opened_rate,cast(t1.clicked*100.0/(t1.email_sent-t1.bounced) as DECIMAL(10, 2))as click_rate
  from t1
 where t1.email_subject_id=7 and sent_date between '2016-09-01' and '2016-10-31'
 




