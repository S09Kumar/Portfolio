/* 

COVID_19--DATA Exploration Project

Skills Utilized: Join's, Temp Tables, CTE's, Window Functions, Aggregate Functions, Creating Views, Converting Data Types  

*/

select *												
from PortfolioProject..CovidDeaths
where continent is not NULL -- to eliminate empty continent list
order by 3,4

	
 --Data We are going to work with:
	
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2

	
 --Total cases vs total deaths
 --likelihodd of dying if you contract covid in your country
	
select location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths	
where location like '%states%'
and continent is not NULL
order by 1,2

	
 --Total cases vs population
 --shows what percentage of population infected with covid
	
select location, date, population, total_cases, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths	
where location like '%states%'
and continent is not NULL
order by 1,2

	
 --Countries with Highest Infection Rate compared to Population
	
select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS  PercentPopulationInfected
from PortfolioProject..CovidDeaths	
--where location like '%states%'
where continent is not NULL
group by location,population
order by PercentPopulationInfected desc

	
 --Countries with Highest Death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by location
order by TotalDeathCount desc


 --BREAK DOWN BY CONTINENT
	
 --Showcasing continents with highest death count per location
	
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by continent
order by TotalDeathCount desc



 --GLOBAL NUMBERS

select  date, sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/nullif(SUM(new_cases),0)*100 as DeathPercentage 
--(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths	
--where location like '%states%'
where continent is not NULL
group by date
order by 1,2


 --Total Population vs Vaccination
 --Percentage of population that has received atleast one Covid Vaccine

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated--sums total cases for that particular location/country, 
--and orders(increases count) by each date,location for that country.
--,(RollingPeopleVaccinated/population)*100 -- cannot call immedeatly once its created, so use temp table.
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
order by 2,3


 --Using CTE to perform Calculation on Partition By in previous query

with popVSvac (continent,Location,Date,population,New_Vaccin,RollingPeopleVaccinated)--naming the columns
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated--sums total cases for that particular location/country, 
--and orders(increases count) by each date,location for that country.
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
--order by 2,3 --order by cannot be in CTE
)
select *, (RollingPeopleVaccinated/population)*100 as Vacc_Percent
from popVSvac


 --Using Temp Table to Perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated--sums total cases for that particular location/country, 
--and orders(increases count) by each date,location for that country.
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL

select *, (RollingPeopleVaccinated/population)*100 as Vacc_Percent
from #PercentPopulationVaccinated


 --Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(float,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated--sums total cases for that particular location/country, 
--and orders(increases count) by each date,location for that country.
--,(RollingPeopleVaccinated/population)*100 -- cannot call immedeatly once its created, so use temp table.
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL

