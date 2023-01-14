SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Total cases VS Total deaths
SELECT location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
order by 1,2

--Total cases VS Population
SELECT location, date, population, total_cases, (Total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionNumber, MAX((Total_cases/population))*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by CasesPercentage desc

--Countries with highest death count with respect to population
SELECT location, population, MAX(total_deaths) as TotalDeathCount, MAX((total_deaths/population)) as HighestDeathWRTPopulation
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc

--Breaking it down by location
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Breaking it down by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--group by date
order by 1,2


--looking at Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, PeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (PeopleVaccinated/Population)*100
from Popvsvac

--Temp Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,new_vaccinations)) over (partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (PeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualization with Tableau
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,new_vaccinations)) over (partition by dea.Location Order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--drop view PercentPopulationVaccinated

select *
from PercentPopulationVaccinated