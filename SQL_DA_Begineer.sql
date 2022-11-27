Select * from [SQL DA project 1].dbo.Data1;

Select * from [SQL DA project 1].dbo.Data2;


--Count of records in bothe datasets

Select count(*) from Data1;
Select count(*) from Data2;

--fetch jahrkand and bihar
Select * from [SQL DA project 1].dbo.Data1 order by State;

Select * from Data2 where State in ('Jharkhand','Bihar');



--calculate total pop
select sum(Population) Tot_Pop from Data2;


--Avg growth
Select AVG(Growth)*100 Avg_growth from Data1 


--Avg growth by states
Select State,AVG(Growth)*100 Avg_growth from Data1 group by State order by AVG(Growth);


--sum of pop by states
select State, sum(Population) from Data2 group by State;


--Avg sex ratio of states

Select state, round(avg(Sex_Ratio), 0)  ASR from data1 group by State order by round(avg(Sex_Ratio), 0) desc;

--Avg literac rate greate than 85

select state,round(AVG(literacy),2)  ALR from Data1   group by state
having AVG(literacy) > 85 order by ALR desc;


--top 3 states high literacy,  high growth 

--using TOP command
select top 3 state,round(AVG(literacy),2)  ALR, AVG(Growth)*100 Avg_growth  from Data1   group by state order by Avg_growth desc 

--as well as low literacy ie bottom 3
select top 3 state,round(AVG(literacy),2)  ALR, AVG(Growth)*100 Avg_growth  from Data1   group by state order by Avg_growth  


--lowest sex ratio top 3

select top 3 state, round(avg(Sex_Ratio),0) ASR  from data1 group by State order by ASR;



-- top 3 highest and lowest literacy state

--here we need to use some temp table

--Highest  litereacy

drop table if exists TS
create table TS
(
State nvarchar(255),
topstates float
)
insert into TS

select state,round(AVG(literacy),2)  ALR from Data1   group by state  order by ALR desc;


select top 3 * from TS order by topstates desc;


--Lowest  litereacy

drop table if exists LS
create table LS
(
State nvarchar(255),
Lowest_states float
)
insert into LS

select state,round(AVG(literacy),2)  ALR from Data1   group by state  order by ALR ;


select top 3 * from LS order by Lowest_states ;


--Combining Highest and Lowest literacy 
--we ca use UNION operator
--Note: the column must be same

select * from (
select top 3 * from TS order by topstates desc ) H

UNION 

select * from (
select top 3 * from LS order by Lowest_states) L 
order by topstates;


--select states starts with 'a' or 'c'

select distinct state,count(*) total from data1 where lower(State) like 'a%' or  lower(state) like 'c%' group by state



--select states starts with 'a' and ends with 'h'

select distinct state,count(*) total from data1 where lower(State) like 'a%' and  lower(state) like '%h' group by state

select distinct state,count(*) total from data1 where lower(state) like '%h' group by state order by total desc