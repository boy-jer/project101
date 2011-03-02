class InsurancePoliciesController < ApplicationController
  def index
    @insurance_policies = InsurancePolicy.all
  end

  def show
    @insurance_policy = InsurancePolicy.find(params[:id])
  end

  def new
    @insurance_policy = InsurancePolicy.new
    @insurance_policy.setbase
    @insurance_policy.assigned_company_id = current_company.id
    @insurance_policy.parent_company_id = main_company.id
  end

  def create
    @insurance_policy = InsurancePolicy.new(params[:insurance_policy])
    if @insurance_policy.save
      flash[:notice] = "Successfully created insurance policy."
      redirect_to company_customer_path(current_company, @insurance_policy.customer_id)
    else
      render :action => 'new'
    end
  end

  def edit
    @insurance_policy = InsurancePolicy.find(params[:id])
  end

  def update
    @insurance_policy = InsurancePolicy.find(params[:id])
    if @insurance_policy.update_attributes(params[:insurance_policy])
      flash[:notice] = "Successfully updated insurance policy."
      redirect_to insurance_policy_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @insurance_policy = InsurancePolicy.find(params[:id])
    @insurance_policy.destroy
    flash[:notice] = "Successfully destroyed insurance policy."
    redirect_to company_insurance_policies_url(current_company)
  end
end