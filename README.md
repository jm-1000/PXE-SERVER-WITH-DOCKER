## Overview

This project provides a containerized PXE (Preboot Execution Environment) server using Docker. It integrates essential network boot services—**DHCP**, **TFTP**, and **HTTP**—within an isolated Docker environment to enable automated deployment of system images (e.g., via **Clonezilla**) over the network.

The PXE server is designed for rapid provisioning of multiple client machines simultaneously, eliminating the need for manual USB installations. It is configured to start automatically on boot using **systemd**, making it a self-contained, reusable, and portable deployment solution for lab, enterprise, or classroom environments.
