select *
from portfolio_project..covidvaccination
order by 3,4

--select *
--from portfolio_project..coviddeath
--order by 3,4

--selecting data that i am going to be using

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..coviddeath
order by 1,2

--total case vs total deaths

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project..coviddeath
where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows what percantage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as percentofpopulation_infected
from portfolio_project..coviddeath
where location like '%states%'
order by 1,2

--countries with highest infection rate compared to population
select location, population, Max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentofpopulation_infected
from portfolio_project..coviddeath
--where location like '%states%'
group by location, population
order by percentofpopulation_infected desc

--countries with the highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolio_project..coviddeath
where  continent is not null
group by location 
order by totaldeathcount desc


--breaking things down by continent

select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolio_project..coviddeath
where  continent is not null
group by continent 
order by totaldeathcount desc

--the continents with highest death count per population
select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolio_project..coviddeath
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers

select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/ sum(new_cases)* 100 as deathpercentage
from portfolio_project..coviddeath
where continent is not null 
order by 1,2


--total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated

from portfolio_project..coviddeath dea
join portfolio_project..covidvaccination vac
	on dea.location =vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--use cte
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)

as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated

from portfolio_project..coviddeath dea
join portfolio_project..covidvaccination vac
	on dea.location =vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


--temp
drop table if exists  #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric)
 insert into #percentpopulationvaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from portfolio_project.. coviddeath dea
join portfolio_project.. covidvaccination vac
on dea.location =vac.location
and dea.date =vac.date
--where dea.continent is not null


select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating view to store date

create view percentpopulationvccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from portfolio_project.. coviddeath dea
join portfolio_project.. covidvaccination vac
on dea.location =vac.location
and dea.date =vac.date
where dea.continent is not null








