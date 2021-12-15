SELECT *
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- looking at total cases vs total deaths
-- shows the likelyhood of dying if one contract covid in their country
select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid
select location, date, total_cases, population, total_deaths, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location='Australia'
order by 1,2



-- countries with the highest infection rate compared to the population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 desc



-- shows countries with highest death count per population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc


-- break down by continent

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc


-- global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- loking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location and
	dea.date=vac.date
where dea.continent is not null
order by 2,3



--use CTE

with PopvsVac
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location and
	dea.date=vac.date
where dea.continent is not null
)
select continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated/Population) * 100 as PercVaccinated
from PopvsVac


-- create a table for later use

create View PercPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location and
	dea.date=vac.date
where dea.continent is not null


select *
from PercPopulationVaccinated
