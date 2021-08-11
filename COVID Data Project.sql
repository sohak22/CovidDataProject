-- COVID DEATHS TABLE
Select* From portfolioProject ..covid_Deaths$
where continent is not null
order by 3,4


-- Select data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioProject ..covid_Deaths$ 
order by 1,2


-- Looking at Total cases vs total deaths 
-- Shows the likelihood of dying if you get covid in your country, in this case Canada 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioProject ..covid_Deaths$ 
Where location like '%canada%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From portfolioProject ..covid_Deaths$ 
--Where location like '%canada%'
order by 1,2

--Looking at countries with highest infection rate compared to population 

Select Location, MAX(total_cases) AS HighestInfectionCount, population, MAX(total_cases/population)*100 as PercentPopulationInfected
From portfolioProject ..covid_Deaths$ 
--Where location like '%canada%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing countries with Highest Death Count per Population 
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From portfolioProject ..covid_Deaths$ 
where continent is not null
Group by location
order by TotalDeathCount desc


-- Continent breakdown 
-- Showing continents with highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From portfolioProject ..covid_Deaths$ 
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers 
Select  Sum(new_Cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolioProject ..covid_Deaths$ 
Where continent is not null
order by 1,2

-- COVID VACCINATION TABLE JOIN
Select* 
From portfolioProject ..covid_Deaths$ death
JOIN portfolioProject..covid_Deaths$ vac
	ON death.location = vac.location 
	and death.date = vac.date

-- Looking at Total Population vs Vaccinations 

Select death.continent , death.location, death.date, death.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (Partition by death.location Order by death.location, death.date) as RollingVaccinationCount
From portfolioProject..covid_Deaths$ death
Join portfolioProject..covid_vaccinations$ vac
	On death.location = vac.location 
	and death.date = vac.date 
Where death.continent is not null 
order by 1,2,3

-- USE CTE 
With PopvsVac (continent, location, Date, Population,new_vaccinations, RollingVaccinationCount) 
as
(
Select death.continent , death.location, death.date, death.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (Partition by death.location Order by death.location, death.date) as RollingVaccinationCount
From portfolioProject..covid_Deaths$ death
Join portfolioProject..covid_vaccinations$ vac
	On death.location = vac.location 
	and death.date = vac.date 
Where death.continent is not null 
--order by 1,2,3
)
Select *, (RollingVaccinationCount/Population)*100
From PopvsVac

-- TEMP TABLE 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
RollingVaccinationCount numeric
) 
Insert into #PercentPopulationVaccinated
Select death.continent , death.location, death.date, death.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (Partition by death.location Order by death.location, death.date) as RollingVaccinationCount
From portfolioProject..covid_Deaths$ death
Join portfolioProject..covid_vaccinations$ vac
	On death.location = vac.location 
	and death.date = vac.date 
Where death.continent is not null 
order by 1,2,3

Select *, (RollingVaccinationCount/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data fpr later visualizations 

Create view PercentPopulationVaccinated as 
Select death.continent , death.location, death.date, death.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (Partition by death.location Order by death.location, death.date) as RollingVaccinationCount
From portfolioProject..covid_Deaths$ death
Join portfolioProject..covid_vaccinations$ vac
	On death.location = vac.location 
	and death.date = vac.date 
Where death.continent is not null 


Select * 
From PercentPopulationVaccinated


/*
Queries used for Tableau Project
*/

--1

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From portfolioProject..covid_Deaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From portfolioProject..covid_Deaths$
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioProject..covid_Deaths$
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioProject..covid_Deaths$
Group by Location, Population, date
order by PercentPopulationInfected desc
