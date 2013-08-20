# -*- encoding : utf-8 -*-

module SidekiqStatus
  class ClientMiddleware
    def call(worker, item, queue)
      return yield unless worker.is_a?(SidekiqStatus::Worker)

      return yield if item['at']

      jid  = item['jid']
      args = item['args']
      item['args'] = [jid]

      SidekiqStatus::Container.create(
          'jid'    => jid,
          'worker' => worker.name,
          'queue'  => queue,
          'args'   => args
      )

      yield
    rescue Exception => exc
      SidekiqStatus::Container.load(jid).delete rescue nil
      raise exc
    end
  end
end