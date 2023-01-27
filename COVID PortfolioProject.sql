/*COVID 19 Data Exploration
DATA Feb 2, 2020 to Jan 25, 2023
Skills used: Joins, CTE's, Temp Tables, Windows Function, Aggregate Functions, Creating Views, Converting Data Type
*/

Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total cases versus Total deaths
--Likelihood of death upon contraction of covid in the U.S.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where location  like '%states%'
and continent is not null
order by 1,2

--Total cases versus Population
--The percentage of the population infected with Covid in the U.S.
Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location  like '%states%'
and continent is not null
order by 1,2

--Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--Countries with the Highest Death Count per Population
Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
group by location
order by TotalDeathCount desc


--Let's break things down by continent

--Continents with the highest death count per population
Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
group by continent
order by TotalDeathCount desc

--Global numbers
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as bigint)) as Total_Deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Total Population vs Vaccinations
--Percentage of Population that has received at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform calculation on partition by in previous query
With PopvsVac (Continent, Location, Date, Population, new_vaccations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using Temp Table to perform calculation on partition by in previous query
DROP Table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated 
(
Continent nvarchar(255), 
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated
