-- project 3


create database inventary ;
use inventary;
select * from purchase_order;
select * from product_master;
select * from stock_ledger;
select * from vender_performance;
select * from monthly_purchase_summary;


-- monthly purchase value vs buget  

select month, month_no,
count(*) as total_order,
sum(total_cost) as total_value,
sum(case when po_status= "received" then total_cost else 0 end) as received_value,
round(sum(total_cost)/2500000*100,1) as budget_utilization_pct
from purchase_order
group by month,month_no
order by month_no;


-- vendor performance received rate

select vendor,
count(*) as total_pos,
sum(total_cost) as total_value,
sum(case when po_status = "received" then 1 else 0 end) as received_pos,
round(sum(case when po_status ="received" then 1 else 0 end)/count(*)*100,2) as received_rate,
rank() over(order by received_rate desc ) as vendor_rank
from purchase_order
group by vendor
order by received_rate desc;

select vendor ,
count(*) as total_pos,
sum(total_cost) as total_value,
sum(case when po_status = "received" then 1 else 0 end) as received_po ,
round(sum(case when po_status ="received" then 1 else 0 end )/count(*)*100,2) as received_rate,
rank() over (order by received_rate desc ) as vendor_rate_rank 
from purchase_order
group by vendor
order by received_rate desc;

-- category wise puchasr_spend

select category ,
count(*) as total_pos,
sum(total_cost) as total_value,
round(sum(total_cost)/sum(sum(total_cost)) over()*100,2) as total_value_pct
from purchase_order 
where po_status ="received"
group by category
order by total_value_pct desc;


-- low stock alter - recorder required
select 
s.sku_code,s.product_name,s.category,s.current_stock,s.reorder_level,
(s.current_stock-s.reorder_level) as shortage_stock,
p.unit_cost,
(s.reorder_level-s.current_stock)*p.unit_cost as reorder_value
from stock_ledger s join product_master p on s.sku_code=p.sku_code
order by reorder_value desc;


-- . Month-over-Month Growth
select month,month_no,
sum(total_cost) as net_rev,
lag(sum(total_cost)) over (order by month_no) as prev_rev,
round((sum(total_cost)-lag(sum(total_cost)) over(order by month_no))/lag(sum(total_cost)) over (order by month_no)*100,2) as mom_growth
from purchase_order
group by month, month_no
order by month_no;

