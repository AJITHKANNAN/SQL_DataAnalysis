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



--Advanced SQL

--1) Calculate no.of males and females

select * from Data1;
select * from Data2;

-- Joining
select d1.District,d1.State,d1.Sex_Ratio, d2.Population
from Data1 d1 join Data2 d2 on d1.District = d2.District

/*
--Note:

--sex_ratio = females/males  ---(1)

--males+ females = population  --(2)

-- from 2    females = population - males  --->(3)

--from 1    females = sex_ratio * males  ---> (4)

sub 3 in 4

population - males = sex_ratio * males

population = sex_ratio * males + males --> 
population = males( sex_ratio +1)

**
males = population /  ( sex_ratio +1)
**

sub males in 3

females = population - (population /  ( sex_ratio +1))

females = population (1- 1/( sex_ratio +1))

**
females = (population * sex_ratio ) / ( sex_ratio +1)
**


males = population /  ( sex_ratio +1)
females = (population * sex_ratio ) / ( sex_ratio +1)

*/

--Total no.of males and females "DISTRICT" wise
select District, State, round((population /  ( sex_ratio +1)),0) males,  round(((population * sex_ratio ) / ( sex_ratio +1)),0) females from
(select d1.District,d1.State,d1.Sex_Ratio/1000 sex_ratio, d2.Population from Data1 d1 join Data2 d2 on d1.District = d2.District ) c

--Total no.of males and females "STATE" wise

select d.State, sum(d.males) total_males, sum(d.females) total_females from
(select District, State, round((population /  ( sex_ratio +1)),0) males,  round(((population * sex_ratio ) / ( sex_ratio +1)),0) females from
(select d1.District,d1.State,d1.Sex_Ratio/1000 sex_ratio, d2.Population from Data1 d1 join Data2 d2 on d1.District = d2.District ) c )  d
group by d.State  order by total_females desc, total_males desc



select * from Data1;
select * from Data2

/*
Calulating literacy rate

Literacy_ratio = total_literate_people / population

total_literate_people= Literacy_ratio * population

total_il-literate_people= (1-Literacy_ratio) * population


*/

select d1.District, d1.State, d1.Literacy/100 lit_ratio, d2.Population from Data1 d1 join Data2 d2 on d1.District= d2.District;


-- total litracy rate by DISTRICT
select c.State,c.District, round((c.Literacy*c.Population),0) total_literate, round(((1-c.Literacy)*c.Population),0) total_il_literate from (
select d1.District,d1.State,d1.Literacy/100 Literacy, d2.Population  from Data1 d1 join Data2 d2 on d1.District = d2.District ) c;


-- total literacy rate by STATE


select State, sum(d.total_literate) literate, sum(d.total_il_literate) il_literate from
(select c.State,c.District, round((c.Literacy*c.Population),0) total_literate, round(((1-c.Literacy)*c.Population),0) total_il_literate from (
select d1.District,d1.State,d1.Literacy/100 Literacy, d2.Population  from Data1 d1 join Data2 d2 on d1.District = d2.District ) c ) d 
group by d.State ;



--Q) find population in previous census

/*
 present_pop = previous_pops + (growth*previous_pop)

present_pop = previous_pops( 1+ growth)


--previous_pops = present_pop / ( 1+ growth)
*/

--District wise census
select  District, State,round((c.Population/ (1+ c.Growth)),0) prev_pop , c.Population from
(select d1.District,d1.State,d1.Growth, d2.Population  from Data1 d1 join Data2 d2 on d1.District = d2.District) c


--state wise census

select d.State, sum(d.prev_pop) total_previous_pop, sum(d.Population) total_present_pop from
(select  District, State,round((c.Population/ (1+ c.Growth)),0) prev_pop , c.Population from
(select d1.District,d1.State,d1.Growth, d2.Population  from Data1 d1 join Data2 d2 on d1.District = d2.District) c) d
group by d.State



--Total pop of India previous and present and the difference between both census

select f.present_census, f.previous_census ,(f.present_census-f.previous_census) diff ,round((f.present_census/ f.previous_census),2) growth_percent from
(select sum(e.total_present_pop) present_census, sum(e.total_previous_pop) previous_census  from 
(select d.State, sum(d.prev_pop) total_previous_pop, sum(d.Population) total_present_pop from
(select  District, State,round((c.Population/ (1+ c.Growth)),0) prev_pop , c.Population from
(select d1.District,d1.State,d1.Growth, d2.Population  from Data1 d1 join Data2 d2 on d1.District = d2.District) c) d
group by d.State ) e
 ) f


 --As population increase the area will decrease
 --calculate the area/person decreased
 --population vs area


--total area of india  --[2]
select '1' as keyy, z.* from
(select sum(d.Area_km2) total_area  from Data2 d) z;

--total pops present and previous --[1]
select '1' as keyy, n.previous_census, n.present_census from
(select f.present_census, f.previous_census ,(f.present_census-f.previous_census) diff ,round((f.present_census/ f.previous_census),2) growth_percent from
(select sum(e.total_present_pop) present_census, sum(e.total_previous_pop) previous_census  from 
(select d.State, sum(d.prev_pop) total_previous_pop, sum(d.Population) total_present_pop from
(select  District, State,round((c.Population/ (1+ c.Growth)),0) prev_pop , c.Population from
(select d1.District,d1.State,d1.Growth, d2.Population  from Data1 d1 join Data2 d2 on d1.District = d2.District) c) d
group by d.State ) e
 ) f ) n

 --for finding area / person we need to join [1] & [2]

select q.*, m.total_area from
(select '1' as keyy, n.previous_census, n.present_census from
(select f.present_census, f.previous_census ,(f.present_census-f.previous_census) diff ,round((f.present_census/ f.previous_census),2) growth_percent from
(select sum(e.total_present_pop) present_census, sum(e.total_previous_pop) previous_census  from 
(select d.State, sum(d.prev_pop) total_previous_pop, sum(d.Population) total_present_pop from
(select  District, State,round((c.Population/ (1+ c.Growth)),0) prev_pop , c.Population from
(select d1.District,d1.State,d1.Growth, d2.Population  from Data1 d1 join Data2 d2 on d1.District = d2.District) c) d
group by d.State ) e
 ) f ) n) q

join (
select '1' as keyy, z.* from
(select sum(d.Area_km2) total_area  from Data2 d) z) m on m.keyy= q.keyy




select (area_pop.total_area/ area_pop.previous_census)*100 prev, (area_pop.total_area/area_pop.present_census)*100 present ,
((area_pop.total_area/ area_pop.previous_census)*100 - (area_pop.total_area/area_pop.present_census)*100 ) *100 diff from 
(select q.*, m.total_area from
(select '1' as keyy, n.previous_census, n.present_census from
(select f.present_census, f.previous_census ,(f.present_census-f.previous_census) diff ,round((f.present_census/ f.previous_census),2) growth_percent from
(select sum(e.total_present_pop) present_census, sum(e.total_previous_pop) previous_census  from 
(select d.State, sum(d.prev_pop) total_previous_pop, sum(d.Population) total_present_pop from
(select  District, State,round((c.Population/ (1+ c.Growth)),0) prev_pop , c.Population from
(select d1.District,d1.State,d1.Growth, d2.Population  from Data1 d1 join Data2 d2 on d1.District = d2.District) c) d
group by d.State ) e
 ) f ) n) q

join (
select '1' as keyy, z.* from
(select sum(d.Area_km2) total_area  from Data2 d) z) m on m.keyy= q.keyy ) as area_pop

--Anaswer:  There was a 4.73+ percentage difference between prev and present which will lead to shortage of AREA



--Windows function:
-- Q)  top 3 district from each STATES with high literacy 

select  a.* from
(select State,District,Literacy, rank() over(partition by state order by Literacy desc) Rnk from Data1 ) a
where a.Rnk in (1,2,3) order by State

-- bottom 3  district from each STATES with low literacy 
select  b.* from
(select State,District,Literacy, rank() over(partition by state order by Literacy ) Rnk from Data1 ) b
where b.Rnk in (1,2,3) order by State

