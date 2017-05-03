require 'phydo/presenters/storage_proxy_presenter'

module StorageControllerBehavior
  extend ActiveSupport::Concern
  require 'phydo/storage_proxy_client'

  def show
    begin
      storage_proxy_response = storage_proxy.status(filename).body
    rescue Faraday::ConnectionFailed => e
      storage_proxy_response = {"name" => @filename, "status" => 'disabled'}.to_json
    end

    @storage_proxy_presenter = Phydo::StorageProxyPresenter.new(storage_proxy_response, file_set_solr_document)
    super
  end

  def stage
    begin
      stage_file filename
      redirect_options = { notice: "Stage request for #{filename} has been sent" }
    rescue Faraday::ConnectionFailed => e
      redirect_options = { alert: "ERROR: Stage request for #{filename} failed." }
    end
    redirect_to(main_app.url_for(controller: :file_sets, action: :show, id: params[:id]), redirect_options)
  end

  def unstage
    begin
      unstage_file filename
      redirect_options = { notice: "Unstage request for #{filename} has been sent" }
    rescue Faraday::ConnectionFailed => e
      redirect_options = { alert: "ERROR: Unstage request for #{filename} failed." }
    end
    redirect_to(main_app.url_for(controller: :file_sets, action: :show, id: params[:id]), redirect_options)
  end

  def fixity
    begin
      check_fixity filename
      redirect_options = { notice: "Fixity check request for #{filename} has been sent" }
    rescue Faraday::ConnectionFailed => e
      redirect_options = { alert: "ERROR: Fixity check request for #{filename} failed." }
    end
    redirect_to(main_app.url_for(controller: :file_sets, action: :show, id: params[:id]), redirect_options)
  end

  private

  def file_set_solr_document
    @file_set_solr_document ||= FileSet.search_with_conditions(id: params[:id]).first
  end

  def filename
    @filename ||= File.basename(file_set_solr_document['filename_tesim']&.first.to_s)
  end

  def get_file_status
    default_resp = {"name" => @filename, "status" => 'disabled'}
    if storage_proxy.enabled?
      response = storage_proxy.status @filename
      response.body
    else
      default_resp.to_json
    end
  end

  def stage_file(filename)
    default_resp = {"name" => filename, "type" => 'stage', "status" => 'disabled'}
    if storage_proxy.enabled?
      response = storage_proxy.stage filename
      response.body
    else
      default_resp.to_json
    end
  end

  def unstage_file(filename)
    default_resp = {"name" => @filename, "type" => 'unstage', "status" => 'disabled'}
    if storage_proxy.enabled?
      response = storage_proxy.unstage @filename
      response.body
    else
      default_resp.to_json
    end
  end

  def check_fixity(filename, fixity_type = 'md5')
    default_resp = {"name" => @filename, "type" => 'fixity', "fixity_type" => fixity_type, "status" => 'disabled'}
    if storage_proxy.enabled?
      response = storage_proxy.fixity @filename
      response.body
    else
      default_resp.to_json
    end
  end

  def storage_proxy
    @storage_proxy ||= Phydo::StorageProxyClient.new
  end

end
