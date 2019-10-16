# -*- coding: utf-8 -*-
"""
Created on Wed Nov  1 21:32:53 2017

@author: Erik
"""

import numpy as np
#from scipy import stats

class Scenario(object):
    def __init__(self, name, goal, budget, admin_pct, fundr_eff, acq_cost):
        self.name = name
        self.goal = goal
        self.budget = budget
        self.admin_pct = admin_pct
        self.fundr_eff = fundr_eff
        self.acq_cost = acq_cost
        
class Region(object):
    def __init__(self, name, acres_u, acres_sd, uplift_u, uplift_sd,
                 support_cost_u, support_cost_sd, imp_cost_u, imp_cost_sd, 
                 maint_cost_u, maint_cost_sd, rent):
        self.name = str(name)
        self.acres_u = acres_u
        self.acres_sd = acres_sd
        self.uplift_u = uplift_u
        self.uplift_sd = uplift_sd
        self.support_cost_u = support_cost_u
        self.support_cost_sd = support_cost_sd
        self.imp_cost_u = imp_cost_u
        self.imp_cost_sd = imp_cost_sd
        self.maint_cost_u = maint_cost_u
        self.maint_cost_sd = maint_cost_sd
        self.rent = rent
    
    def __repr__(self):
        return "Region " + self.name
    
    def getAcres (self):
        min_x, max_x = 0.01, 10000
        x = 0
        while x <= min_x or x >= max_x:
            x = np.random.normal(self.acres_u, self.acres_sd, 1)[0]
        return x
    
    def getUplift (self):
        min_x, max_x = 0, 1        
        x = 0
        while x <= min_x or x >= max_x:
            x = np.random.normal(self.uplift_u, self.uplift_sd, 1)[0]
        return x
    
    def getSupport_Cost (self):
        min_x, max_x = 0, 100000
        x = 0
        while x <= min_x or x >= max_x:
            x = np.random.normal(self.support_cost_u, 
                                 self.support_cost_sd, 1)[0]
        return x
    
    def getImp_Cost (self):
        min_x, max_x = 1000, 100000
        x = 0
        while x <= min_x or x >= max_x:
            x = np.random.normal(self.imp_cost_u, self.imp_cost_sd, 1)[0]
        return x
    
    def getMaint_Cost (self):
        min_x, max_x = 0, 100000
        x = 0
        while x <= min_x or x >= max_x:
            x = np.random.normal(self.maint_cost_u, self.maint_cost_sd, 1)[0]
        return x
    
    def getAcq_Cost(self):
        return self.acq_cost
    
    def getRent(self):
        return self.rent
    
class Project(object):
    projectID = 0
    
    def __init__(self, term, acres, uplift, support_cost, imp_cost, maint_cost, rent):
        self.ID = Project.projectID
        self.term = term
        self.acres = acres
        self.uplift = uplift
        self.facres = acres * uplift
        self.support_cost = support_cost
        self.imp_cost = imp_cost
        self.maint_cost = maint_cost
        self.rent = rent
        self.cost = support_cost + imp_cost + term * (maint_cost + rent)
        self.efficiency = self.cost/self.facres
        Project.projectID += 1
        
    def __repr__(self):
        return "Project " + str(self.ID) + "; " + str(self.facres) + " F-Acres" \
    + "; $" + str(round(self.efficiency,2)) + " per F-Acre"

def resetProjectID():
    Project.projectID = 0
            
def createProjects(number, region):
    projects = []
    for i in range(number):
        term = 5
        acres = region.getAcres()
        uplift = region.getUplift()
        support_cost = region.getSupport_Cost()
        imp_cost = region.getImp_Cost()
        maint_cost = region.getMaint_Cost()
        rent = region.getRent()
        projects.append(Project(term, acres, uplift, support_cost, imp_cost, 
                                maint_cost, rent))
    return projects

def sortProjects(projects):
    return sorted(projects, key = lambda project: project.efficiency)

def fundProgram (expenses, Scenario):
    admin = expenses * Scenario.admin_pct
    fundr = expenses * Scenario.fundr_eff
    program_budget = expenses - admin - fundr
    return admin, fundr, program_budget
    
def fundProjects(projects, goal, program_budget):
    # consider adding year and acquisition costs here
    selected_projects = []
    facres = 0
    program_cost = 0
    projects_remain = len(projects)
    while facres <= goal and program_cost <= program_budget and \
    projects_remain > 0:
        project = projects[0]
        selected_projects.append(project)
        facres += project.facres
        program_cost += project.cost
        projects_remain -= 1
        projects = projects[1:]
    return selected_projects, facres, program_cost

# Run simulation
#Create Region 'South Central'
name = "South_Central"
acres_u, acres_sd = 100, 25
uplift_u, uplift_sd = .4, .25
support_cost_u, support_cost_sd = 100, 10
imp_cost_u, imp_cost_sd = 1000, 100
maint_cost_u, maint_cost_sd = 100, 10
rent = 0
South_Central = Region(name, acres_u, acres_sd, uplift_u, uplift_sd, 
                       support_cost_u, support_cost_sd, imp_cost_u, 
                       imp_cost_sd, maint_cost_u, maint_cost_sd, rent)
#Create Scenario1
name = "Scenario1"
goal = 0.4*(10**6)
budget = 20*(10**6)
admin_pct = 0.06
fundr_eff = 0.14
acq_cost = 100
Scenario1 = Scenario(name, goal, budget, admin_pct, fundr_eff, acq_cost)

resetProjectID()

num_projects = 50000
projects = createProjects(num_projects, South_Central)
projects_sorted = sortProjects(projects)



admin, fundr, program_budget = fundProgram (budget, Scenario1)
selected_projects, facres, program_cost = fundProjects(projects_sorted, 
                                                       goal, program_budget)

#Metrics
funded_projects = len(selected_projects)

eff = []
for p in projects_sorted:
    eff.append(p.efficiency)
eff = np.array(eff)