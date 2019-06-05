"""Tests for Gulp Installer."""

import unittest
import mock
from grow.common import base_config
from grow.sdk.installers import base_installer
from grow.sdk.installers import gulp_installer
from grow.testing import mocks
from grow.testing import storage as test_storage


class GulpInstallerTestCase(unittest.TestCase):
    """Test the Gulp Installer."""

    def _make_gulpfile(self):
        self.test_fs.write('gulpfile.js', '')

    def setUp(self):
        self.test_fs = test_storage.TestFileStorage()
        self.config = base_config.BaseConfig()
        env = mocks.mock_env(name="testing")
        self.pod = mocks.mock_pod(
            env=env, root='/testing/', storage=self.test_fs.storage)
        self.installer = gulp_installer.GulpInstaller(
            self.pod, self.config)

    @mock.patch('subprocess.call')
    def test_check_prerequisites(self, mock_call):
        """Check prerequisites for gulp."""
        mock_call.return_value = 0
        self.installer.check_prerequisites()
        mock_call.assert_called_once_with(
            'gulp --version > /dev/null 2>&1', **self.installer.subprocess_args(shell=True))

    @mock.patch('subprocess.call')
    def test_check_prerequisites_fail(self, mock_call):
        """Fails check prerequisites for gulp."""
        mock_call.return_value = 127
        with self.assertRaises(base_installer.MissingPrerequisiteError):
            self.installer.check_prerequisites()

    def test_install(self):
        """Install should not error for gulp."""
        self.installer.install()

    def test_should_run(self):
        """Installer should run."""
        self.assertFalse(self.installer.should_run)
        self._make_gulpfile()
        self.assertTrue(self.installer.should_run)
