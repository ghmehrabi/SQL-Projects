
SELECT *

FROM portfolioproject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY  location,date

-----------------------------------------

--SELECT *

--FROM portfolioproject.dbo.CovidVacination
--order by 3,4

----------------------------------------
--select data that we are going to be use:

SELECT [location] , [date] , total_deaths , total_cases, new_cases , [population]

FROM PortfolioProject.dbo.CovidDeaths
ORDER BY [location] , [date] 

---------------------------------------
--looking at Total cases and Total Deaths

SELECT [location] , [date] , total_deaths ,  total_cases , (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage

FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%IRAN%' 
AND continent IS NOT NULL
ORDER BY [location] , [date]
----------------------------------------
--Looking at Total Cases vs Population
--Shows What Percentage of Population Got Covid

SELECT [location] , [date] ,[population] ,  total_cases , (CAST(total_cases AS float)/CAST(population AS float))*100 AS [percentpopulationinfected]

FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%IRAN%' 
AND continent IS NOT NULL
ORDER BY [location] , [date]

------------------------------------------
SELECT [location] , [date] ,[population] ,  total_cases , (CAST(total_cases AS float)/CAST(population AS float))*100 AS [percentpopulationinfected]

FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%IRAN%' 
WHERE continent IS NOT NULL
ORDER BY [location] , [date]
-------------------------------------------

--looking at contries with highest infection rate compared to population:

SELECT location ,
       population ,
	   MAX(total_cases) AS [Highest Infection Count] ,
	   MAX((CAST(total_cases AS float)/CAST(population AS float)))*100 AS [percent population infected]

FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location] , population
ORDER BY [percent population infected] desc

------------------------------------------------
--Showing Contries With Highest Death Count Per Population:

SELECT location,
       MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
Group BY location
ORDER BY TotalDeathCount DESC

----------------------------------------------

---Let's Break Things Down By Continent 
---Showing Continents With the Highest Death Count Per Population:

SELECT continent,
       MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
Group BY continent
ORDER BY TotalDeathCount DESC

------------------------------------------------

SELECT location,
       MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS  NULL
Group BY location
ORDER BY TotalDeathCount DESC

----------------------------------------------

---Global Numbers

SELECT [date] ,
       SUM(new_cases) AS totalcases , 
       SUM(CAST(new_deaths AS int)) AS totaldeaths,
       ROUND(SUM(CAST(new_deaths AS float))/ SUM(CAST(new_cases AS float))*100 , 2) AS DeathPercentage

FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL and new_cases != 0  and new_cases is not null
GROUP BY  [date]
ORDER BY date 

-------------------------------------------------
--JOIN 2 TABLES:

SELECT *
FROM PortfolioProject.dbo.CovidDeaths  AS dea
JOIN PortfolioProject.dbo.CovidVacination AS vac
      ON dea.location = vac.location
	  AND dea.date = vac.date

---Looking at Total Population vs Vaccinations :

SELECT dea.continent, dea.location ,  dea.date , dea.population , vac.new_vaccinations 
       ,SUM( CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths  AS dea
JOIN PortfolioProject.dbo.CovidVacination AS vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY  location , population

--------------------------------------------

---USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated )

AS
(
SELECT dea.continent, dea.location ,  dea.date , dea.population , vac.new_vaccinations 
       ,SUM( CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths  AS dea
JOIN PortfolioProject.dbo.CovidVacination AS vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY  location , population
)
SELECT *

FROM PopVsVac


------------------------------------------------

--TEMPT TABLE

DROP TABLE IF exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location  nvarchar(255),
date  datetime,
population  numeric,
new_vaccinations  numeric,
RollingPeopleVaccinated  numeric,
)

INSERT INTO #percentpopulationvaccinated

SELECT dea.continent, dea.location ,  dea.date , dea.population , vac.new_vaccinations 
       ,SUM( CONVERT(bigint,vac.new_vaccinations)) 
	   OVER (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths  AS dea
JOIN PortfolioProject.dbo.CovidVacination AS vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY  location , population

SELECT *

FROM #percentpopulationvaccinated

-------------------------------------------------

--Creating View to Store Data for later Visualizations :

CREATE View percentpopulationvaccinated AS
SELECT dea.continent, dea.location ,  dea.date , dea.population , vac.new_vaccinations 
       ,SUM( CONVERT(bigint,vac.new_vaccinations)) 
	   OVER (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths  AS dea
JOIN PortfolioProject.dbo.CovidVacination AS vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY  location , population

------------------------------------------------









