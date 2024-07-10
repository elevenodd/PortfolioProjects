--Select data that we will be using

SELECT location, date, total_cases,total_deaths
FROM PortfolioProject..Covid_Deaths
ORDER BY 1,2

-- Total cases vs Total Deaths (likelihood of death if contracted Covid)
SELECT location, date, total_cases,total_deaths, round((total_deaths/total_cases) * 100, 2) as death_percentage
FROM PortfolioProject..Covid_Deaths
WHERE location IN ('Lebanon', 'United States')
ORDER BY  1, 2

-- Total cases VS population (showing what percentage got Covid)
SELECT location, date, total_cases,population,  (total_cases/population) * 100  as PopulationInfection_rate
FROM PortfolioProject..Covid_Deaths
WHERE location like '%states%'
ORDER BY  1, 2

-- Looking at countries with highest infection rate

SELECT
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases / population) * 100) AS PopulationInfection_rate
FROM PortfolioProject..Covid_Deaths
GROUP BY location, population
ORDER BY PopulationInfection_rate desc;

-- Countries with hgihest death count per population

SELECT
    location,
    MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..Covid_Deaths
where continent is not null
GROUP BY location
order by total_death_count desc

-- let's break it out by continent

SELECT
    continent,
    MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..Covid_Deaths
where continent is not null
GROUP BY continent
order by total_death_count desc

-- Global numbers 

SELECT date, 
		sum(new_cases) as total_cases,
		sum(cast(new_deaths as int)) as total_deaths,
		sum(cast(new_deaths as int))  /sum(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths
where continent is not null and new_cases != 0
GROUP BY date
ORDER BY date, sum(new_cases);


-- total Global numbers

SELECT 
		sum(new_cases) as total_cases,
		sum(cast(new_deaths as int)) as total_deaths,
		sum(cast(new_deaths as int))  /sum(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths
where continent is not null 
-- GROUP BY date
-- ORDER BY date;

-- total population vs vaccinations
select  dea.continent, dea.location,vac.date, vac.new_vaccinations
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac 
	on
		dea.location = vac.location
		and 
		dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Running total of vaccinations
select  dea.continent, dea.location,vac.date, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as Rolling_ppl_Vaccinations
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac 
	on
		dea.location = vac.location
		and 
		dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- FINDING THE PERCENTAGE OF POPULATION VACCINATED BY USING THE QUERY ABOCE AS A CTE TABLE

WITH population_vaccinated (continent, location, date, population, new_vaccinations, Rolling_ppl_Vaccinations)

AS (
SELECT  dea.continent, dea.location,vac.date, population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as Rolling_ppl_Vaccinations
from PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac 
	on
		dea.location = vac.location
		and 
		dea.date = vac.date
WHERE dea.continent is not null) 
-- order by 2,3

select * , round((Rolling_ppl_Vaccinations/population) * 100, 2) as percentage_pop_vaccinated
from population_vaccinated

-- TEMP TABLE FOR THE SAME (QUERY ABOVE)

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_ppl_Vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT  dea.continent, dea.location,vac.date, population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as Rolling_ppl_Vaccinations
FROM PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac 
	on
		dea.location = vac.location
		and 
		dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


SELECT *,  round((Rolling_ppl_Vaccinations/population) * 100, 2) AS percentage_pop_vaccinated
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

drop view if exists Percent_Population_Vaccinated
CREATE VIEW Percent_Population_Vaccinated AS

SELECT  dea.continent, dea.location,vac.date, population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as Rolling_ppl_Vaccinations
FROM PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac 
	on
		dea.location = vac.location
		and 
		dea.date = vac.date
WHERE dea.continent is not null

select *
from Percent_Population_Vaccinated