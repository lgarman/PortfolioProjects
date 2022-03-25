Select *
	From PortfolioProject..CovidDeaths
	--Where continent is not null
	order by 3,4

	--Select *
	--From PortfolioProject..CovidVaccinations
	--order by 3,4

	Select Location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..CovidDeaths
	order by 1,2
	
	--Looking at Total Cases vs Total Deaths
	--shows likelihood of dying if you contract covid in your country
	Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 AS DeathPercentage
	From PortfolioProject..CovidDeaths
	--Where location like '%states%'
	order by 1,2

	--Looking at Total Cases Vs Population
	--shows what percentage of population contracted covid
	Select Location, date, Population, total_cases, (Total_cases/Population)*100 AS PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	--where location like '%states'
	order by 1,2

	--Looking at countries with highest infection rate compared to population
	Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((Total_cases/Population))*100 AS PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	--where location like '%states'
	Group by Location, Population
	order by PercentPopulationInfected desc

	--Showing Countries with highest death count per population
	Select Location,MAX(cast(total_deaths as int)) AS TotalDeathCount
	From PortfolioProject..CovidDeaths
	--where location like '%states'
	Where continent is not null
	Group by Location
	order by TotalDeathCount desc

	--Breaking down by continent
	--Showing continents with the highest death count
	Select continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by continent
	order by TotalDeathCount desc

	--Global Numbers
	Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
	From PortfolioProject..CovidDeaths
	where continent is not null
	Group by date
	order by 1,2
--Overall death percentage 
	Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
	From PortfolioProject..CovidDeaths
	where continent is not null
	--Group by date
	order by 1,2

	--Looking at total population vs vaccination

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date)
		AS RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location=vac.location 
		and dea.date=vac.date
	where dea.continent is not null
	Order by 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date)
		AS RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location=vac.location 
		and dea.date=vac.date
	where dea.continent is not null
	)
	Select *, (RollingPeopleVaccinated/Population)*100 
	From PopvsVac

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	continent nvarchar(255), 
	location nvarchar(255), 
	Date datetime, population numeric, 
	new_vaccinations numeric, 
	RollingPeopleVaccinated Numeric
	)

	Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date)
		AS RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location=vac.location 
		and dea.date=vac.date
	where dea.continent is not null
	
	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated

	--Create View to store data for later visualizations
	Create View PercentPeopleVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date)
		AS RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location=vac.location 
		and dea.date=vac.date
	where dea.continent is not null

	Select *
	From PercentPeopleVaccinated
