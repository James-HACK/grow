from . import base
from protorpc import messages
from grow.pods.storage import storage as storage_lib
import os


class Config(messages.Message):
  out_dir = messages.StringField(1)


class LocalDeployment(base.BaseDeployment):
  NAME = 'local'
  Config = Config
  storage = storage_lib.FileStorage

  def get_destination_address(self):
    return self.config.out_dir

  def read_file(self, path):
    path = os.path.join(self.out_dir, path.lstrip('/'))
    return self.storage.read(path)

  def delete_file(self, path):
    out_path = os.path.join(self.out_dir, path.lstrip('/'))
    self.storage.delete(out_path)

  def write_file(self, path, content):
    if isinstance(content, unicode):
      content = content.encode('utf-8')
    out_path = os.path.join(self.out_dir, path.lstrip('/'))
    self.storage.write(out_path, content)