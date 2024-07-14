select * from PortfolioProject..covid_deaths
order by 3,4


--select data that we are going to be using

select location, date, total_cases,new_cases,total_deaths,population
from PortfolioProject..covid_deaths
where continent is not null
order by 1,2


-- looking at Total Cases vs Total Deaths
--shows likelihood of dying if you are infected with covid in nepal

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covid_deaths
where location = 'Nepal' and continent is not null
order by 1,2

--Looking at Total Cases vs Population
-- showing what percentage of popuation got covid

select location, date, total_cases,population, (total_cases/population)*100 as PopultionInfectionPercent
from PortfolioProject..covid_deaths
--where location = 'Nepal'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population,max(total_cases) as Highestinfectioncountry,max((total_cases/population))*100 as PopultionInfectionPercent
from PortfolioProject..covid_deaths
group by location,population
order by PopultionInfectionPercent desc



--showing countries with highest death count per population

select location, max(cast(total_Deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc


-- showing by continent
-- showing the continent with highest death count per population

select location, max(cast(total_Deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
where continent is  null
group by location
order by TotalDeathCount desc


-- Global Numbers
select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 as DeathPercentage
from PortfolioProject..covid_deaths
where continent is not null
--group by date
order by 1,2



--joining covid_deaths and covid Vaccination

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccination vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null
order by 2,3


-- USE CTE 
with PopvsVac(Continent,Location,Date,Population,New_Vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccination vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null

)

select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(250),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccination vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null

select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualiation

create view 
PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location) as RollingPeopleVaccinated
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccination vac
on dea.location=vac.location
and dea.date =vac.date
where dea.continent is not null


select * from PercentPopulationVaccinated









